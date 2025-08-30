import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/background_job_service.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  String _tempPhone = '';
  String _tempInviteCode = '';
  
  // Verification status tracking
  String? _verificationStatus;
  String? _verificationStage;
  Map<String, dynamic>? _verificationDetails;
  
  // Background job tracking
  List<String> _activeJobIds = [];
  Map<String, Map<String, dynamic>> _jobStatuses = {};

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get tempPhone => _tempPhone;
  String get tempInviteCode => _tempInviteCode;
  bool get isLoggedIn => _currentUser != null;
  bool get needsFaceRegistration => _currentUser?.isNew == true;
  
  // Verification status getters
  String? get verificationStatus => _verificationStatus;
  String? get verificationStage => _verificationStage;
  Map<String, dynamic>? get verificationDetails => _verificationDetails;
  
  // Job tracking getters
  List<String> get activeJobIds => List.unmodifiable(_activeJobIds);
  Map<String, Map<String, dynamic>> get jobStatuses => Map.unmodifiable(_jobStatuses);

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error state
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set temporary phone and invite code during registration
  void setTempCredentials(String phone, String inviteCode) {
    _tempPhone = phone;
    _tempInviteCode = inviteCode;
    notifyListeners();
  }

  // Clear temporary credentials
  void clearTempCredentials() {
    _tempPhone = '';
    _tempInviteCode = '';
    notifyListeners();
  }

  // Set current user
  void setUser(User user) {
    _currentUser = user;
    _error = null;
    notifyListeners();
  }

  // Update user data
  void updateUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  // Update user status
  void updateUserStatus(String status) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(status: status);
      notifyListeners();
    }
  }

  // Update user face data after successful face registration
  void updateUserFaceData({
    String? uid,
    String? rekognitionFaceId,
    String? s3Key,
    double? livenessScore,
  }) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        uid: uid,
        rekognitionFaceId: rekognitionFaceId,
        s3Key: s3Key,
        livenessScore: livenessScore,
        status: 'verified',
        lastSeen: DateTime.now(),
        accessCount: _currentUser!.accessCount + 1,
      );
      notifyListeners();
    }
  }

  // Logout user
  void logout() {
    _currentUser = null;
    _error = null;
    _tempPhone = '';
    _tempInviteCode = '';
    notifyListeners();
  }

  // Create user from registration data
  User createUserFromRegistration() {
    return User(
      phone: _tempPhone,
      inviteCode: _tempInviteCode,
      status: 'new',
      createdAt: DateTime.now(),
      lastSeen: DateTime.now(),
    );
  }

  // Check if user exists and return user data
  bool hasUserData() {
    return _currentUser != null;
  }

  // Get user registration progress
  String getRegistrationProgress() {
    if (_currentUser == null) return 'Not started';
    
    switch (_currentUser!.status) {
      case 'new':
        return 'Phone verified - Face scan needed';
      case 'pending':
        return 'Face scan complete - Under verification';
      case 'verified':
        return 'Registration complete';
      case 'failed':
        return 'Verification failed';
      default:
        return 'Unknown status';
    }
  }

  // Get next step for user
  String getNextStep() {
    if (_currentUser == null) return 'Please log in';
    
    switch (_currentUser!.status) {
      case 'new':
        return 'Complete face scan';
      case 'pending':
        return 'Wait for verification';
      case 'verified':
        return 'Ready to use app';
      case 'failed':
        return 'Retry face scan';
      default:
        return 'Contact support';
    }
  }
  
  // Load current user from backend
  Future<bool> loadCurrentUser() async {
    setLoading(true);
    clearError();
    
    try {
      final result = await AuthService.getCurrentUser();
      
      if (result['success'] == true) {
        final userData = result['user'];
        final user = User.fromJson(userData);
        setUser(user);
        return true;
      } else {
        setError(result['message'] ?? 'Failed to load user data');
        return false;
      }
    } catch (e) {
      setError('Failed to load user: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  // Refresh verification status from backend
  Future<bool> refreshVerificationStatus() async {
    try {
      final result = await AuthService.getUserVerificationStatus();
      
      if (result['success'] == true) {
        _verificationStatus = result['status'];
        _verificationStage = result['verificationStage'];
        _verificationDetails = result['details'];
        notifyListeners();
        return true;
      } else {
        setError(result['message'] ?? 'Failed to get verification status');
        return false;
      }
    } catch (e) {
      setError('Failed to refresh verification status: $e');
      return false;
    }
  }
  
  // Update verification status in backend
  Future<bool> updateVerificationStatus({
    required String status,
    String? stage,
    Map<String, dynamic>? details,
  }) async {
    try {
      final result = await AuthService.updateUserVerificationStatus(
        status: status,
        verificationStage: stage,
        details: details,
      );
      
      if (result['success'] == true) {
        _verificationStatus = status;
        if (stage != null) _verificationStage = stage;
        if (details != null) _verificationDetails = details;
        
        // Also update the user status if we have a user
        if (_currentUser != null) {
          updateUserStatus(status);
        }
        
        notifyListeners();
        return true;
      } else {
        setError(result['message'] ?? 'Failed to update verification status');
        return false;
      }
    } catch (e) {
      setError('Failed to update verification status: $e');
      return false;
    }
  }
  
  // Add active job ID for tracking
  void addActiveJob(String jobId) {
    if (!_activeJobIds.contains(jobId)) {
      _activeJobIds.add(jobId);
      notifyListeners();
    }
  }
  
  // Remove job from active tracking
  void removeActiveJob(String jobId) {
    _activeJobIds.remove(jobId);
    _jobStatuses.remove(jobId);
    notifyListeners();
  }
  
  // Update job status
  void updateJobStatus(String jobId, String status, Map<String, dynamic> data) {
    _jobStatuses[jobId] = {
      'status': status,
      'data': data,
      'updatedAt': DateTime.now(),
    };
    notifyListeners();
  }
  
  // Handle job completion
  void handleJobCompleted(String jobId, Map<String, dynamic> result) {
    // Update job status
    updateJobStatus(jobId, 'completed', result);
    
    // If it's a face matching job and successful, update user data
    if (result.containsKey('isMatch') && result.containsKey('confidence')) {
      final isMatch = result['isMatch'] as bool?;
      final confidence = result['confidence'] as double?;
      
      if (isMatch == false && confidence != null) {
        // New face registered successfully
        updateUserFaceData(
          uid: result['uid'],
          livenessScore: confidence,
        );
        updateVerificationStatus(status: 'verified', stage: 'face');
      } else if (isMatch == true) {
        // Duplicate detected
        updateVerificationStatus(status: 'failed', stage: 'face', details: {
          'reason': 'duplicate_face',
          'message': 'Face already registered by another user',
        });
      }
    }
    
    // Remove from active jobs
    removeActiveJob(jobId);
  }
  
  // Handle job failure
  void handleJobFailed(String jobId, String error) {
    updateJobStatus(jobId, 'failed', {'error': error});
    removeActiveJob(jobId);
    
    // Set error state
    setError('Job failed: $error');
  }
  
  // Track if job monitoring is already initialized
  bool _isJobMonitoringInitialized = false;
  
  // Initialize background job monitoring with navigation callbacks
  void initializeJobMonitoring({
    Function()? onNavigateToIdentity,
    Function(String)? onNavigateToFaceScanWithError,
  }) {
    // Prevent duplicate initialization
    if (_isJobMonitoringInitialized) {
      print('🔄 Job monitoring already initialized, skipping...');
      return;
    }
    
    print('🚀 Initializing job monitoring for the first time');
    _isJobMonitoringInitialized = true;
    
    BackgroundJobService.onJobStatusUpdate = updateJobStatus;
    BackgroundJobService.onJobCompleted = handleJobCompleted;
    BackgroundJobService.onJobFailed = handleJobFailed;
    
    // Set up navigation callbacks
    BackgroundJobService.onVerificationSuccess = () async {
      // Load user data from /me API
      final success = await handleVerificationSuccess();
      
      if (success) {
        // Call the navigation callback to move to identity screen
        onNavigateToIdentity?.call();
      } else {
        // If loading user data failed, show error and go back to face scan
        onNavigateToFaceScanWithError?.call('Failed to load user data after verification');
      }
    };
    
    BackgroundJobService.onVerificationFailed = (String errorMessage) {
      // Navigate back to face scan with error message
      onNavigateToFaceScanWithError?.call(errorMessage);
    };
    
    BackgroundJobService.startPolling();
  }
  
  // Stop background job monitoring
  void stopJobMonitoring() {
    BackgroundJobService.stopPolling();
  }
  
  // Check if user needs face verification
  Future<bool> checkNeedsFaceVerification() async {
    return await AuthService.needsFaceVerification();
  }
  
  // Enhanced logout that cleans up everything
  Future<void> logoutAndCleanup() async {
    stopJobMonitoring();
    _isJobMonitoringInitialized = false; // Reset initialization flag
    _activeJobIds.clear();
    _jobStatuses.clear();
    _verificationStatus = null;
    _verificationStage = null;
    _verificationDetails = null;
    logout();
    await AuthService.clearAuthData();
    print('✅ Complete logout and cleanup finished');
  }
  
  // Handle successful verification - load user data from /me API
  Future<bool> handleVerificationSuccess() async {
    setLoading(true);
    clearError();
    
    try {
      // Call /me API to get fresh user data
      final result = await AuthService.getCurrentUser();
      
      if (result['success'] == true) {
        final userData = result['user'];
        final user = User.fromJson(userData);
        
        // Update user with verified status
        final verifiedUser = user.copyWith(
          status: 'verified',
          lastSeen: DateTime.now(),
          accessCount: user.accessCount + 1,
        );
        
        setUser(verifiedUser);
        
        // Mark onboarding as complete
        await AuthService.completeOnboarding();
        
        print('✅ User verification successful and data loaded');
        return true;
      } else {
        setError(result['message'] ?? 'Failed to load user data after verification');
        return false;
      }
    } catch (e) {
      setError('Failed to load user data: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
}
