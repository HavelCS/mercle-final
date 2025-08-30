import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class FaceVerificationScreen extends StatefulWidget {
  final String sessionId;

  const FaceVerificationScreen({Key? key, required this.sessionId})
    : super(key: key);

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isVerifying = true;
  String _statusMessage = 'Verifying your face...';
  Map<String, dynamic>? _verificationResult;
  int _currentAttempt = 0;
  int _maxAttempts = 12; // 1 minute with 5-second intervals

  @override
  void initState() {
    super.initState();

    // Set up loading animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat();

    // Start face verification polling
    _startFaceVerification();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startFaceVerification() async {
    setState(() {
      _isVerifying = true;
      _statusMessage = 'Analyzing your face scan...';
    });

    try {
      final result = await AuthService.processLivenessResultsWithPolling(
        widget.sessionId,
        maxAttempts: _maxAttempts,
        pollInterval: const Duration(seconds: 5),
      );

      setState(() {
        _isVerifying = false;
        _verificationResult = result;
        _animationController.stop();
      });

      _handleVerificationResult(result);
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _statusMessage = 'Verification failed. Please try again.';
        _animationController.stop();
      });
    }
  }

  void _handleVerificationResult(Map<String, dynamic> result) {
    final success = result['success'] ?? false;
    final duplicateDetected = result['duplicateDetected'];

    if (success) {
      if (duplicateDetected == true) {
        // Show duplicate face detected dialog
        _showDuplicateFaceDialog(result);
      } else {
        // New user - proceed to complete onboarding
        _proceedToNextScreen(isNewUser: true, result: result);
      }
    } else {
      // Verification failed
      setState(() {
        _statusMessage = result['message'] ?? 'Face verification failed';
      });

      // Show retry option after a delay
      Future.delayed(const Duration(seconds: 3), () {
        _showRetryDialog();
      });
    }
  }

  void _showDuplicateFaceDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text(
                'Face Already Registered',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This face is already associated with another account.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Match Confidence: ${((result['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'User ID: ${result['uid'] ?? 'Unknown'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'You can either:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Use a different phone number to login to that account',
              ),
              const Text('• Contact support if this is an error'),
              const Text('• Try again with a different face'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showRetryDialog();
              },
              child: const Text('Try Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to phone login
                _goBackToLogin();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Use Different Number'),
            ),
          ],
        );
      },
    );
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Verification Failed'),
          content: Text(
            _verificationResult?['message'] ??
                'Face verification failed. Please try again.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _goBackToLogin();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Go back to face scan
                Navigator.of(context).pop();
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  void _proceedToNextScreen({
    required bool isNewUser,
    required Map<String, dynamic> result,
  }) {
    // Complete onboarding for new users
    if (isNewUser) {
      AuthService.completeOnboarding();
    }

    // Navigate to success screen or main app
    // Replace with your actual navigation logic
    Navigator.of(context).pushReplacementNamed('/identity-active');
  }

  void _goBackToLogin() {
    // Navigate back to phone login screen
    // Replace with your actual navigation logic
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/phone-login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated verification icon
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _isVerifying
                                ? Colors.blue.withOpacity(0.1)
                                : (_verificationResult?['success'] == true
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1)),
                        border: Border.all(
                          color:
                              _isVerifying
                                  ? Colors.blue.withOpacity(0.3)
                                  : (_verificationResult?['success'] == true
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.3)),
                          width: 2,
                        ),
                      ),
                      child:
                          _isVerifying
                              ? Transform.rotate(
                                angle: _animation.value * 2 * 3.14159,
                                child: const Icon(
                                  Icons.face_retouching_natural,
                                  size: 60,
                                  color: Colors.blue,
                                ),
                              )
                              : Icon(
                                _verificationResult?['success'] == true
                                    ? Icons.check_circle
                                    : Icons.error,
                                size: 60,
                                color:
                                    _verificationResult?['success'] == true
                                        ? Colors.green
                                        : Colors.red,
                              ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Status title
                Text(
                  _isVerifying
                      ? 'Under Verification'
                      : (_verificationResult?['success'] == true
                          ? 'Verification Complete'
                          : 'Verification Failed'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Status message
                Text(
                  _statusMessage,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),

                if (_isVerifying) ...[
                  const SizedBox(height: 24),

                  // Progress indicator
                  Text(
                    _currentAttempt > 0
                        ? 'Attempt $_currentAttempt of $_maxAttempts'
                        : 'Processing...',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  // Linear progress indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _currentAttempt / _maxAttempts,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                      minHeight: 6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Information text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Please wait while we verify your face scan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This usually takes less than a minute',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                if (!_isVerifying &&
                    _verificationResult?['success'] != true) ...[
                  // Action buttons for failed verification
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Go back to face scan
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Try Face Scan Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: _goBackToLogin,
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
