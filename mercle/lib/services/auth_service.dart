import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'https://fastapi.mercle.ai/api';
  static const String _tokenKey = 'access_token';
  static const String _phoneKey = 'user_phone';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  // New endpoints from GitHub backend
  static const String _authEndpoint = '/auth';
  static const String _usersEndpoint = '/users';
  static const String _facesEndpoint = '/faces';

  // Store JWT token and user phone
  static Future<void> saveAuthData(String token, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_phoneKey, phone);
  }

  // Get stored JWT token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user phone
  static Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Clear auth data (logout)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_onboardingCompleteKey);
  }

  // Mark onboarding as complete
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
    print('✅ Onboarding completed!');
  }

  // Check if onboarding is complete
  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  // Get authorization headers
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Update token if X-New-Access-Token header is present
  static Future<void> updateTokenIfNeeded(http.Response response) async {
    final newToken =
        response.headers['X-New-Access-Token'] ??
        response.headers['x-new-access-token'];
    if (newToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, newToken);
      print('🔄 JWT token refreshed automatically');
    }
  }

  // Start OTP verification with invite code
  static Future<Map<String, dynamic>> startOTP(
    String phoneNumber, {
    String? inviteCode,
  }) async {
    try {
      final body = {'phone': phoneNumber};
      if (inviteCode != null && inviteCode.isNotEmpty) {
        body['invite_code'] = inviteCode;
      }

      print('🔄 Sending OTP request to: $_baseUrl/auth/start-otp');
      print('📱 Phone: $phoneNumber');
      print('🎫 Invite code: $inviteCode');
      print('📦 Request body: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/start-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');
      print('📡 Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        print('✅ OTP sent successfully');
        return {'success': true, 'message': 'OTP sent successfully'};
      } else {
        print('❌ OTP request failed with status: ${response.statusCode}');
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      print('💥 Network error occurred: $e');
      print('💥 Error type: ${e.runtimeType}');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Verify OTP and get JWT token
  static Future<Map<String, dynamic>> verifyOTP(
    String phoneNumber,
    String otpCode,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phoneNumber, 'code': otpCode}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Save JWT token and phone number
        await saveAuthData(data['access_token'], phoneNumber);

        return {
          'success': true,
          'message': 'OTP verified successfully',
          'token': data['access_token'],
          'expires_in': data['expires_in'],
        };
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['detail'] ?? 'Invalid OTP'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Get current user profile from new backend
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_usersEndpoint/me'),
        headers: headers,
      );

      // Update token if needed
      await updateTokenIfNeeded(response);

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return {'success': true, 'user': userData};
      } else if (response.statusCode == 401) {
        // Token expired or invalid - clear auth data
        await clearAuthData();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'requiresAuth': true,
        };
      } else {
        return {'success': false, 'message': 'Failed to fetch user data'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Create liveness session using new backend structure
  static Future<Map<String, dynamic>> createLivenessSession() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl$_facesEndpoint/liveness/create-session'),
        headers: headers,
      );

      // Update token if needed
      await updateTokenIfNeeded(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'sessionId': data['sessionId']};
      } else if (response.statusCode == 401) {
        await clearAuthData();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'requiresAuth': true,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Failed to create session',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Process face liveness results (authenticated)
  static Future<Map<String, dynamic>> processFaceLivenessResults(
    String sessionId, {
    double? confidence,
    bool? isLive,
    List<String>? auditImages,
    String? faceImage,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/faces/face-liveness/verify'),
        headers: headers,
        body: json.encode({
          'sessionId': sessionId,
          'confidence': confidence ?? 0.9,
          'isLive': isLive ?? true,
          'auditImages': auditImages,
          'faceImage': faceImage,
        }),
      );

      // Update token if needed
      await updateTokenIfNeeded(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'],
          'isLive': data['isLive'],
          'isNewFace': data['isNewFace'],
          'userId': data['userId'],
          'confidence': data['confidence'],
          'livenessScore':
              data.containsKey('livenessScore')
                  ? data['livenessScore']
                  : data['confidence'],
          'message': data['message'],
        };
      } else if (response.statusCode == 401) {
        await clearAuthData();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'requiresAuth': true,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Failed to process results',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Process liveness results using new backend structure
  static Future<Map<String, dynamic>> processLivenessResults(
    String sessionId,
  ) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl$_facesEndpoint/liveness/process-results'),
        headers: headers,
        body: json.encode({'sessionId': sessionId}),
      );

      // Update token if needed
      await updateTokenIfNeeded(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'],
          'isNewFace': data['isNewFace'],
          'uid': data['uid'],
          'confidence': data['confidence'],
          'livenessScore': data['livenessScore'],
        };
      } else if (response.statusCode == 401) {
        await clearAuthData();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'requiresAuth': true,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Failed to process results',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Check user verification status
  static Future<Map<String, dynamic>> getUserVerificationStatus() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_usersEndpoint/verification-status'),
        headers: headers,
      );

      // Update token if needed
      await updateTokenIfNeeded(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'status': data['status'], // new, pending, verified, failed, rejected
          'verificationStage':
              data['verificationStage'], // phone, face, document, complete
          'lastUpdated': data['lastUpdated'],
          'details': data['details'],
        };
      } else if (response.statusCode == 401) {
        await clearAuthData();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'requiresAuth': true,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Failed to get verification status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Update user verification status
  static Future<Map<String, dynamic>> updateUserVerificationStatus({
    required String status,
    String? verificationStage,
    Map<String, dynamic>? details,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final Map<String, dynamic> body = {'status': status};

      if (verificationStage != null) {
        body['verificationStage'] = verificationStage;
      }

      if (details != null) {
        body['details'] = details;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl$_usersEndpoint/update-verification-status'),
        headers: headers,
        body: json.encode(body),
      );

      // Update token if needed
      await updateTokenIfNeeded(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'status': data['status'],
          'message': data['message'],
        };
      } else if (response.statusCode == 401) {
        await clearAuthData();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'requiresAuth': true,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Failed to update verification status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Check if user needs face verification
  static Future<bool> needsFaceVerification() async {
    final statusResult = await getUserVerificationStatus();
    if (statusResult['success'] == true) {
      final status = statusResult['status'];
      final stage = statusResult['verificationStage'];
      return status == 'new' ||
          status == 'pending' ||
          (status == 'verified' && stage != 'complete');
    }
    return false; // Default to false if we can't determine status
  }

  // Process liveness results with polling for duplicate detection
  static Future<Map<String, dynamic>> processLivenessResultsWithPolling(
    String sessionId, {
    int maxAttempts = 20, // 10 minutes with 30-second intervals
    Duration pollInterval = const Duration(seconds: 30),
  }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      attempts++;
      print(
        '🔍 Polling attempt $attempts/$maxAttempts for session: $sessionId',
      );

      try {
        // First check if user status changed to verified in database
        final userStatusResult = await getUserVerificationStatus();
        if (userStatusResult['success'] == true && userStatusResult['status'] == 'verified') {
          print('✅ User status changed to verified in database, stopping face scan polling');
          return {
            'success': true,
            'isNewFace': true,
            'uid': null,
            'confidence': 100.0,
            'livenessScore': 100.0,
            'duplicateDetected': false,
            'message': 'User verification completed via database status change',
          };
        }
        
        final result = await processLivenessResults(sessionId);

        // If successful, return the result
        if (result['success'] == true) {
          final isNewFace = result['isNewFace'];

          if (isNewFace == false) {
            // Face matched - existing user detected
            return {
              'success': true,
              'isNewFace': false,
              'uid': result['uid'],
              'confidence': result['confidence'],
              'livenessScore': result['livenessScore'],
              'duplicateDetected': true,
              'message': 'Face matched with existing user',
            };
          } else {
            // New face - no duplicate
            return {
              'success': true,
              'isNewFace': true,
              'uid': result['uid'],
              'confidence': result['confidence'],
              'livenessScore': result['livenessScore'],
              'duplicateDetected': false,
              'message': 'New face registered successfully',
            };
          }
        }

        // If not successful but no error, continue polling
        if (result['success'] == false && result['message'] != null) {
          if (result['message'].toString().toLowerCase().contains('expired') ||
              result['message'].toString().toLowerCase().contains('invalid')) {
            // Session expired or invalid - stop polling
            return result;
          }
        }
      } catch (e) {
        print('❌ Error during polling attempt $attempts: $e');

        // If it's the last attempt, return the error
        if (attempts >= maxAttempts) {
          return {
            'success': false,
            'message': 'Face verification timeout. Please try again.',
            'duplicateDetected': null,
          };
        }
      }

      // Wait before next poll (unless it's the last attempt)
      if (attempts < maxAttempts) {
        print(
          '⏳ Waiting ${pollInterval.inSeconds} seconds before next poll...',
        );
        await Future.delayed(pollInterval);
      }
    }

    // Timeout reached
    return {
      'success': false,
      'message':
          'Face verification timeout after ${maxAttempts * pollInterval.inSeconds} seconds. Please try again.',
      'duplicateDetected': null,
    };
  }
}
