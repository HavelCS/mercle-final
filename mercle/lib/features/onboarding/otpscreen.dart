import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:mercle/constants/colors.dart';
import 'package:mercle/services/auth_service.dart';
import 'package:mercle/features/face-scan/screens/facescan-home.dart';
import 'package:mercle/features/onboarding/verification-success.dart';
import 'package:mercle/common/otp-textfield.dart';
import 'package:mercle/providers/user_provider.dart';
import 'package:mercle/models/user.dart';

class OtpScreen extends StatefulWidget {
  static const String routeName = "/otp-verification";
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _hasError = false;

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final result = await AuthService.verifyOTP(
      widget.phoneNumber,
      _otpController.text,
    );

    setState(() {
      _isLoading = false;
      if (!result['success']) {
        _hasError = true;
        // Don't clear the OTP field, just show error state
      }
    });

    if (result['success'] && mounted) {
      // Get user provider and create user with temp credentials
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = User(
        phone: widget.phoneNumber,
        inviteCode: userProvider.tempInviteCode,
        status: 'new',
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
      );

      // Set user in provider
      userProvider.setUser(user);

      // Navigate to verification success screen first
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const VerificationSuccessScreen(),
        ),
      );

      // After 1.5 seconds, navigate to face scan setup
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, FaceScanSetup.routeName);
        }
      });
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _otpController.clear();
    });

    // Get invite code from provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final result = await AuthService.startOTP(
      widget.phoneNumber,
      inviteCode: userProvider.tempInviteCode,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success'] && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 29.w, right: 29.w, top: 110.h),
          child: Column(
            children: [
              Center(child: SvgPicture.asset("assets/images/logo.svg")),
              SizedBox(height: 110.h),
              Text(
                'Enter the code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 44.sp,
                  fontFamily: 'HandjetRegular',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'We sent a code to ${widget.phoneNumber}, please enter to verify your address',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF888888),
                  fontSize: 16.sp,
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w400,
                  height: 1.45.h,
                  letterSpacing: -0.16,
                ),
              ),
              SizedBox(height: 32.h),

              // OTP input field using custom widget with error state
              OtpTextField(
                controller: _otpController,
                hasError: _hasError,
                onChanged: (value) {
                  if (_hasError) {
                    setState(() {
                      _hasError = false;
                    });
                  }
                },
                onCompleted: (pin) {
                  // Auto-verify when all 6 digits are entered
                  if (pin.length == 6) {
                    _verifyOTP();
                  }
                },
              ),
              SizedBox(height: 24.h),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
              SizedBox(height: 16.h),

              // Resend OTP button
              TextButton(
                onPressed: _isLoading ? null : _resendOTP,
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 8.h),

              // Change phone number button
              TextButton(
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          Navigator.pop(context);
                        },
                child: const Text(
                  'Change Phone Number',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
