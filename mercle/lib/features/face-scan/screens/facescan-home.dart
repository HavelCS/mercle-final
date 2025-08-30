import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mercle/constants/colors.dart';
import 'package:mercle/widgets/verify_humanity_card.dart';
import 'package:mercle/widgets/webview_face_liveness.dart';
import 'package:mercle/services/auth_service.dart';
import 'package:mercle/utils/verification_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:mercle/providers/user_provider.dart';

class FaceScanSetup extends StatefulWidget {
  static const String routeName = '/face-scan-setup';
  const FaceScanSetup({super.key});

  @override
  State<FaceScanSetup> createState() => _FaceScanSetupState();
}

class _FaceScanSetupState extends State<FaceScanSetup> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  bool _isLoading = false;

  /// Validate current token and refresh if needed
  Future<bool> _validateAndRefreshToken() async {
    try {
      // Try to get current user to validate token
      final userResult = await AuthService.getCurrentUser();

      if (userResult['success'] == true) {
        print('✅ Token is valid');
        return true;
      } else if (userResult['requiresAuth'] == true) {
        print('❌ Token expired or invalid');
        // Show dialog asking user to re-authenticate
        if (mounted) {
          _showTokenExpiredDialog();
        }
        return false;
      } else {
        print('⚠️ Unknown token validation error: ${userResult['message']}');
        return false;
      }
    } catch (e) {
      print('❌ Error validating token: $e');
      return false;
    }
  }

  /// Launch face liveness webview and handle the complete verification flow
  Future<void> _startFaceScan() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 0: Validate token first
      final tokenValidation = await _validateAndRefreshToken();
      if (!tokenValidation) {
        _showErrorDialog('Authentication expired. Please login again.');
        return;
      }

      // Step 1: Create liveness session
      final sessionResult = await AuthService.createLivenessSession();

      if (sessionResult['success'] != true) {
        _showErrorDialog(
          sessionResult['message'] ?? 'Failed to create face scan session',
        );
        return;
      }

      final sessionId = sessionResult['sessionId'];
      print('🎬 Created liveness session: $sessionId');

      // Step 2: Launch WebView for face liveness detection
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    title: const Text(
                      'Face Scan',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.black,
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  body: WebViewFaceLiveness(
                    sessionId: sessionId, // Pass session ID to webview
                    onResult: (result) {
                      Navigator.of(context).pop(); // Close webview
                      _handleFaceScanResult(result, sessionId);
                    },
                    onError: (error) {
                      Navigator.of(context).pop(); // Close webview
                      _showErrorDialog(error);
                    },
                    onCancel: () {
                      Navigator.of(context).pop(); // Close webview
                    },
                  ),
                ),
          ),
        );
      }
    } catch (e) {
      print('Error starting face scan: $e');
      _showErrorDialog('Failed to start face scan. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handle face scan result and proceed to verification
  void _handleFaceScanResult(FaceLivenessResult result, String sessionId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (result.success && result.isLive) {
      print('✅ Face scan successful, proceeding to verification...');

      // Add session to active jobs for tracking
      userProvider.addActiveJob(sessionId);

      // Show "Under Verification" modal and start polling
      _showVerificationBottomSheet(sessionId);
    } else {
      _showErrorDialog(
        result.message.isNotEmpty
            ? result.message
            : 'Face scan failed. Please try again.',
      );
    }
  }

  /// Show verification bottom sheet with polling
  void _showVerificationBottomSheet(String sessionId) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _VerificationBottomSheetContent(
            sessionId: sessionId,
            onVerificationComplete: (success, result) {
              Navigator.of(context).pop(); // Close bottom sheet

              if (success) {
                _handleVerificationSuccess(result);
              } else {
                _handleVerificationFailure(result);
              }
            },
          ),
    );
  }

  /// Handle successful verification
  void _handleVerificationSuccess(Map<String, dynamic> result) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Update user data based on verification result
    if (result['duplicateDetected'] == false) {
      // New user - update face data and complete onboarding
      userProvider.updateUserFaceData(
        uid: result['uid'],
        livenessScore: result['livenessScore']?.toDouble(),
      );

      // Mark onboarding as complete
      AuthService.completeOnboarding();

      // Navigate to success screen or main app
      Navigator.pushReplacementNamed(context, '/verification-success');
    } else {
      // Duplicate detected
      _showDuplicateFaceDialog(result);
    }
  }

  /// Handle verification failure
  void _handleVerificationFailure(Map<String, dynamic> result) {
    _showErrorDialog(
      result['message'] ?? 'Face verification failed. Please try again.',
    );
  }

  /// Show duplicate face detected dialog
  void _showDuplicateFaceDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('Face Already Registered'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'This face is already registered with another account.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Allow retry
                },
                child: const Text('Try Again'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate back to phone login
                  Navigator.pushReplacementNamed(
                    context,
                    '/phone-verification',
                  );
                },
                child: const Text('Use Different Number'),
              ),
            ],
          ),
    );
  }

  /// Show token expired dialog with re-authentication option
  void _showTokenExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.access_time, color: Colors.orange),
                SizedBox(width: 8),
                Text('Session Expired'),
              ],
            ),
            content: const Text(
              'Your authentication session has expired. Please login again to continue.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Clear auth data and navigate to login
                  AuthService.clearAuthData();
                  Navigator.pushReplacementNamed(
                    context,
                    '/phone-verification',
                  );
                },
                child: const Text('Login Again'),
              ),
            ],
          ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// Temporary logout functionality for testing
  Future<void> _handleLogout() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Show confirmation dialog
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text(
                'Are you sure you want to logout? This will clear all your session data.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
      );

      if (shouldLogout == true) {
        // Perform complete logout and cleanup
        await userProvider.logoutAndCleanup();

        // Navigate back to phone verification
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/phone-verification',
            (route) => false,
          );
        }
      }
    } catch (e) {
      print('❌ Error during logout: $e');
      _showErrorDialog('Failed to logout. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        actions: [
          // Temporary logout button
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout (Temporary)',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 34.w, right: 34.w, top: 25.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: SvgPicture.asset("assets/images/logo.svg")),
            SizedBox(height: 33.h),
            Container(height: 449.h, width: 336.w),
            SizedBox(height: 24.h),
            Container(
              height: 88.h,
              width: 336.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                color: Color(0xff454545).withOpacity(0.4),
              ),
              child: Text(
                'Face visible. No mask. No sunglasses.',
                style: TextStyle(
                  color: const Color(0xFFCCCCCC),
                  fontSize: 22.27.sp,
                  fontFamily: 'HandjetRegular',
                  fontWeight: FontWeight.w400,
                  height: 1.45.h,
                  letterSpacing: -0.22,
                ),
              ),
            ),
            SizedBox(height: 27.h),
            GestureDetector(
              onTap: _isLoading ? null : _startFaceScan,
              child: Container(
                height: 54.h,
                width: 161.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: _isLoading ? Colors.grey : Colors.white,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF040414),
                            ),
                          ),
                        )
                        : Text(
                          'Start Face Scan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF040414),
                            fontSize: 16.sp,
                            fontFamily: 'GeistRegular',
                            fontWeight: FontWeight.w400,
                            height: 1.12,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Verification Bottom Sheet Widget
class _VerificationBottomSheetContent extends StatefulWidget {
  final String sessionId;
  final Function(bool success, Map<String, dynamic> result)
  onVerificationComplete;

  const _VerificationBottomSheetContent({
    required this.sessionId,
    required this.onVerificationComplete,
  });

  @override
  State<_VerificationBottomSheetContent> createState() =>
      _VerificationBottomSheetContentState();
}

class _VerificationBottomSheetContentState
    extends State<_VerificationBottomSheetContent>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPolling = true;
  String _statusMessage = 'Verifying your face scan...';
  int _attempts = 0;
  final int _maxAttempts = 20; // 10 minutes total with 30-second intervals

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _startVerificationPolling();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _startVerificationPolling() async {
    try {
      final result = await AuthService.processLivenessResultsWithPolling(
        widget.sessionId,
        maxAttempts: _maxAttempts,
        pollInterval: const Duration(seconds: 30), // Changed from 5 to 30 seconds
      );

      setState(() {
        _isPolling = false;
        _animationController.stop();
      });

      // Notify parent with result
      widget.onVerificationComplete(result['success'] ?? false, result);
    } catch (e) {
      setState(() {
        _isPolling = false;
        _statusMessage = 'Verification failed. Please try again.';
        _animationController.stop();
      });

      widget.onVerificationComplete(false, {'message': 'Verification failed'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isPolling)
              RotationTransition(
                turns: _animationController,
                child: const Icon(Icons.refresh, size: 64, color: Colors.blue),
              )
            else
              const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              _isPolling ? 'Under Verification' : 'Verification Complete',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_isPolling)
              const LinearProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}
