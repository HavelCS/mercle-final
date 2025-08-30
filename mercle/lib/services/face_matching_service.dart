import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FaceMatchingService {
  static const String _baseUrl = 'https://fastapi.mercle.ai/api';
  static const String _facesEndpoint = '/faces';

  // Enqueue face matching job
  static Future<Map<String, dynamic>> enqueueFaceMatching({
    required String faceImage,
    String? sessionId,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final body = {'face_image': faceImage};

      if (sessionId != null) {
        body['session_id'] = sessionId;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl$_facesEndpoint/matching/enqueue'),
        headers: headers,
        body: json.encode(body),
      );

      // Update token if needed
      await AuthService.updateTokenIfNeeded(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'jobId': data['jobId'],
          'estimatedTime': data['estimatedTime'],
          'status': data['status'],
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
          'message': error['detail'] ?? 'Failed to enqueue face matching',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Get face matching job status
  static Future<Map<String, dynamic>> getFaceMatchingJobStatus(
    String jobId,
  ) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_facesEndpoint/matching/status/$jobId'),
        headers: headers,
      );

      // Update token if needed
      await AuthService.updateTokenIfNeeded(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'status': data['status'], // pending, processing, completed, failed
          'progress': data['progress'],
          'result': data['result'], // null if not completed
          'error': data['error'], // null if no error
          'estimatedTimeRemaining': data['estimatedTimeRemaining'],
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

  // Get face matching job results
  static Future<Map<String, dynamic>> getFaceMatchingResults(
    String jobId,
  ) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_facesEndpoint/matching/results/$jobId'),
        headers: headers,
      );

      // Update token if needed
      await AuthService.updateTokenIfNeeded(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'isMatch': data['isMatch'],
          'confidence': data['confidence'],
          'existingUserId': data['existingUserId'],
          'duplicateDetected': data['isMatch'] == true,
          'matchDetails': data['matchDetails'],
        };
      } else if (response.statusCode == 401) {
        await AuthService.clearAuthData();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'requiresAuth': true,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Results not found or job not completed',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Failed to get results',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Poll face matching job until completion
  static Future<Map<String, dynamic>> pollFaceMatchingJob(
    String jobId, {
    int maxAttempts = 50, // 2 minutes with 5-second intervals
    Duration pollInterval = const Duration(minutes: 2),
  }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      attempts++;
      print(
        '🔍 Polling face matching job $attempts/$maxAttempts for job: $jobId',
      );

      try {
        final statusResult = await getFaceMatchingJobStatus(jobId);

        if (statusResult['success'] != true) {
          return statusResult; // Return error immediately
        }

        final status = statusResult['status'];
        print(
          '📊 Job status: $status (${statusResult['progress'] ?? 0}% complete)',
        );

        if (status == 'completed') {
          // Job completed, get results
          final results = await getFaceMatchingResults(jobId);
          return results;
        } else if (status == 'failed') {
          return {
            'success': false,
            'message': statusResult['error'] ?? 'Face matching job failed',
            'duplicateDetected': null,
          };
        }

        // Job still in progress (pending/processing)
        if (attempts < maxAttempts) {
          print(
            '⏳ Job still ${status}, waiting ${pollInterval.inSeconds} seconds...',
          );
          await Future.delayed(pollInterval);
        }
      } catch (e) {
        print('❌ Error during polling attempt $attempts: $e');

        // If it's the last attempt, return the error
        if (attempts >= maxAttempts) {
          return {
            'success': false,
            'message': 'Face matching timeout. Please try again.',
            'duplicateDetected': null,
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
          'Face matching timeout after ${maxAttempts * pollInterval.inSeconds} seconds. Please try again.',
      'duplicateDetected': null,
    };
  }

  // Combined workflow: Enqueue job and poll for results
  static Future<Map<String, dynamic>> matchFaceAndWaitForResults({
    required String faceImage,
    String? sessionId,
    int maxAttempts = 50,
    Duration pollInterval = const Duration(minutes: 2),
  }) async {
    print('🚀 Starting face matching workflow...');

    // Step 1: Enqueue the job
    final enqueueResult = await enqueueFaceMatching(
      faceImage: faceImage,
      sessionId: sessionId,
    );

    if (enqueueResult['success'] != true) {
      return enqueueResult; // Return error if enqueueing failed
    }

    final jobId = enqueueResult['jobId'];
    print('✅ Face matching job enqueued with ID: $jobId');

    // Step 2: Poll for results
    return await pollFaceMatchingJob(
      jobId,
      maxAttempts: maxAttempts,
      pollInterval: pollInterval,
    );
  }
}
