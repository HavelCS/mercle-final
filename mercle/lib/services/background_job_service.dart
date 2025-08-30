import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'face_matching_service.dart';

class BackgroundJobService {
  static const String _baseUrl = 'https://fastapi.mercle.ai/api';
  static const String _jobsEndpoint = '/jobs';

  static Timer? _pollingTimer;
  static bool _isPolling = false;

  // Job status callbacks
  static Function(String jobId, String status, Map<String, dynamic> data)?
  onJobStatusUpdate;
  static Function(String jobId, Map<String, dynamic> result)? onJobCompleted;
  static Function(String jobId, String error)? onJobFailed;

  // Navigation callbacks for verification status changes
  static Function()? onVerificationSuccess; // Navigate to identity screen
  static Function(String message)?
  onVerificationFailed; // Navigate back to face scan with error

  // Start background polling for all user jobs
  static void startPolling({Duration interval = const Duration(minutes: 2)}) {
    if (_isPolling) return;

    _isPolling = true;
    print('🔄 Starting background job polling...');

    _pollingTimer = Timer.periodic(interval, (timer) async {
      await _pollAllJobs();
    });
  }

  // Stop background polling
  static void stopPolling() {
    if (!_isPolling) return;

    _isPolling = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    print('⏹️ Stopped background job polling');
  }

  // Get all user jobs
  static Future<Map<String, dynamic>> getAllUserJobs() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_jobsEndpoint/user'),
        headers: headers,
      );

      // Update token if needed
      await AuthService.updateTokenIfNeeded(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'jobs': data['jobs'],
          'totalJobs': data['totalJobs'],
          'activeJobs': data['activeJobs'],
        };
      } else if (response.statusCode == 401) {
        await AuthService.clearAuthData();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'requiresAuth': true,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Failed to get user jobs',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Get specific job status
  static Future<Map<String, dynamic>> getJobStatus(String jobId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_jobsEndpoint/$jobId/status'),
        headers: headers,
      );

      // Update token if needed
      await AuthService.updateTokenIfNeeded(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'jobId': data['jobId'],
          'type': data['type'], // face_matching, liveness_verification, etc.
          'status': data['status'], // pending, processing, completed, failed
          'progress': data['progress'],
          'result': data['result'],
          'error': data['error'],
          'createdAt': data['createdAt'],
          'updatedAt': data['updatedAt'],
        };
      } else if (response.statusCode == 401) {
        await AuthService.clearAuthData();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'requiresAuth': true,
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Job not found'};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Failed to get job status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Poll all active jobs
  static Future<void> _pollAllJobs() async {
    try {
      final jobsResult = await getAllUserJobs();

      if (jobsResult['success'] == true) {
        final jobs = jobsResult['jobs'] as List;

        for (final job in jobs) {
          final jobId = job['jobId'];
          final currentStatus = job['status'];

          // Only poll active jobs
          if (currentStatus == 'pending') {
            final statusResult = await getJobStatus(jobId);

            if (statusResult['success'] == true) {
              final newStatus = statusResult['status'];

              // Notify status update
              onJobStatusUpdate?.call(jobId, newStatus, statusResult);

              if (newStatus == 'completed') {
                // Job completed
                onJobCompleted?.call(jobId, statusResult['result'] ?? {});
              } else if (newStatus == 'failed') {
                // Job failed
                onJobFailed?.call(
                  jobId,
                  statusResult['error'] ?? 'Unknown error',
                );
              }
            }
          } else if (currentStatus == 'verified') {
            print('✅ Job $jobId is verified - calling success callback');
            // Verification successful - trigger navigation to identity screen and load user data
            onVerificationSuccess?.call();

            // Mark job as completed in the tracking
            onJobCompleted?.call(jobId, {
              'status': 'verified',
              'message': 'Verification completed successfully',
            });
          } else if (currentStatus == 'failed') {
            print('❌ Job $jobId failed - calling failure callback');
            // Verification failed - trigger navigation back to face scan with error
            final errorMessage =
                job['error'] ?? 'Face scan verification failed';
            onVerificationFailed?.call(errorMessage);

            // Mark job as failed in the tracking
            onJobFailed?.call(jobId, errorMessage);
          }
        }
      }
    } catch (e) {
      print('❌ Error polling jobs: $e');
    }
  }

  // Monitor specific job until completion
  static Future<Map<String, dynamic>> monitorJob(
    String jobId, {
    int maxAttempts = 50, // 3 minutes with 5-second intervals
    Duration pollInterval = const Duration(minutes: 2),
  }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      attempts++;
      print('🔍 Monitoring job $attempts/$maxAttempts for job: $jobId');

      try {
        final statusResult = await getJobStatus(jobId);

        if (statusResult['success'] != true) {
          return statusResult; // Return error immediately
        }

        final status = statusResult['status'];
        final progress = statusResult['progress'] ?? 0;
        print('📊 Job $jobId status: $status ($progress% complete)');

        if (status == 'completed') {
          return {
            'success': true,
            'result': statusResult['result'],
            'jobId': jobId,
            'message': 'Job completed successfully',
          };
        } else if (status == 'failed') {
          return {
            'success': false,
            'message': statusResult['error'] ?? 'Job failed',
            'jobId': jobId,
          };
        }

        // Job still in progress (pending/processing)
        if (attempts < maxAttempts) {
          print(
            '⏳ Job $jobId still $status, waiting ${pollInterval.inSeconds} seconds...',
          );
          await Future.delayed(pollInterval);
        }
      } catch (e) {
        print('❌ Error monitoring job $jobId attempt $attempts: $e');

        // If it's the last attempt, return the error
        if (attempts >= maxAttempts) {
          return {
            'success': false,
            'message': 'Job monitoring timeout. Please try again.',
            'jobId': jobId,
          };
        }

        // Otherwise, wait and try again
        if (attempts < maxAttempts) {
          await Future.delayed(pollInterval);
        }
      }
    }

    // Timeout reached
    return {
      'success': false,
      'message':
          'Job monitoring timeout after ${maxAttempts * pollInterval.inSeconds} seconds.',
      'jobId': jobId,
    };
  }

  // Cancel a job
  static Future<Map<String, dynamic>> cancelJob(String jobId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl$_jobsEndpoint/$jobId/cancel'),
        headers: headers,
      );

      // Update token if needed
      await AuthService.updateTokenIfNeeded(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Job cancelled successfully',
        };
      } else if (response.statusCode == 401) {
        await AuthService.clearAuthData();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'requiresAuth': true,
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Job not found'};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Failed to cancel job',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
}
