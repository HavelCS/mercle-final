import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:mercle/services/auth_service.dart';
import 'package:mercle/features/face-scan/screens/identity-active.dart';
import 'package:mercle/utils/face_verification_dialogs.dart';
import 'package:mercle/providers/user_provider.dart';

void showUnderVerificationBottomSheet(BuildContext context, {String? sessionId}) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return _VerificationBottomSheetContent(sessionId: sessionId);
    },
  );
}

class _VerificationBottomSheetContent extends StatefulWidget {
  final String? sessionId;
  
  const _VerificationBottomSheetContent({this.sessionId});
  
  @override
  State<_VerificationBottomSheetContent> createState() => _VerificationBottomSheetContentState();
}

class _VerificationBottomSheetContentState extends State<_VerificationBottomSheetContent> {
  bool _isPolling = false;
  bool _verificationComplete = false;
  String _statusMessage = 'We\'ve put your scan under\nthe verification queue, this might take\nsome time, please check back later.';
  
  @override
  void initState() {
    super.initState();
    // Start polling if we have a session ID
    if (widget.sessionId != null) {
      _startVerificationPolling();
    }
  }
  
  void _startVerificationPolling() async {
    if (_isPolling || widget.sessionId == null) return;
    
    setState(() {
      _isPolling = true;
      _statusMessage = 'Checking verification status...';
    });
    
    try {
      final result = await AuthService.processLivenessResultsWithPolling(
        widget.sessionId!,
        maxAttempts: 20, // 10 minutes with 30-second intervals
        pollInterval: const Duration(seconds: 30),
      );
      
      setState(() {
        _isPolling = false;
        _verificationComplete = true;
      });
      
      _handleVerificationResult(result);
    } catch (e) {
      setState(() {
        _isPolling = false;
        _statusMessage = 'Verification failed. Please try again.';
      });
    }
  }
  
  void _handleVerificationResult(Map<String, dynamic> result) {
    final success = result['success'] ?? false;
    final duplicateDetected = result['duplicateDetected'];
    
    if (success) {
      if (duplicateDetected == true) {
        // Close bottom sheet first
        Navigator.pop(context);
        // Show duplicate face detected dialog
        _showDuplicateFaceDialog(result);
      } else {
        // Close bottom sheet first  
        Navigator.pop(context);
        
        // Update user in provider with verification success
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.updateUserFaceData(
          uid: result['uid'],
          rekognitionFaceId: result['rekognitionFaceId'],
          s3Key: result['s3Key'],
          livenessScore: result['livenessScore']?.toDouble(),
        );
        
        // Complete onboarding and navigate to identity active
        AuthService.completeOnboarding();
        Navigator.pushReplacementNamed(context, IdentityActiveScreen.routeName);
      }
    } else {
      // Close bottom sheet first
      Navigator.pop(context);
      // Show verification error
      showVerificationError(context, result['message'] ?? 'Face verification failed');
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
              const Text(
                'You can either:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text('• Use a different phone number to login to that account'),
              const Text('• Contact support if this is an error'),
              const Text('• Try again with a different face'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to face scan setup for retry
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/face-scan-setup',
                  (route) => false,
                );
              },
              child: const Text('Try Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to phone login
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/phone-verification',
                  (route) => false,
                );
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
  
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 462.h,
        width: 402.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 48.h, left: 32.w, right: 32.w),
          child: Column(
            children: [
              Text(
                'Under verification',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 44.sp,
                  fontFamily: 'HandjetRegular',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF6C6C6C),
                  fontSize: 16.sp,
                  fontFamily: 'GeistRegular',
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  letterSpacing: -0.16,
                ),
              ),
              
              // Show progress indicator when polling
              if (_isPolling) ...[
                SizedBox(height: 24.h),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Verifying your scan...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14.sp,
                    fontFamily: 'GeistRegular',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              SizedBox(height: 67.h),
              Container(
                height: 62.h,
                width: 338.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  color: const Color(0xffF5F5F5),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Check back after ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22.27.sp,
                          fontFamily: 'HandjetRegular',
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                          letterSpacing: -0.22,
                        ),
                      ),
                      TextSpan(
                        text: '1 hour',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22.27.sp,
                          fontFamily: 'HandjetRegular',
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                          letterSpacing: -0.22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 52.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_isPolling) ...[
                    // Check Status Button
                    GestureDetector(
                      onTap: widget.sessionId != null ? _startVerificationPolling : null,
                      child: Container(
                        height: 52.h,
                        width: 140.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: widget.sessionId != null ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Check Status',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontFamily: 'GeistRegular',
                            fontWeight: FontWeight.w400,
                            height: 1.12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                  ],
                  
                  // Close/Continue Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    child: Container(
                      height: 52.h,
                      width: _isPolling ? 161.w : 140.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _isPolling ? Colors.grey : Colors.black,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        _isPolling ? 'Cancel' : 'Continue Later',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
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
            ],
          ),
        ),
      );
  }
}
