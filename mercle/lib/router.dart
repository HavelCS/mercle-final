import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mercle/features/face-scan/screens/device-mockup.dart';
import 'package:mercle/features/face-scan/screens/facescan-home.dart';
import 'package:mercle/features/face-scan/screens/identity-active.dart';
import 'package:mercle/features/face-scan/screens/face_verification_screen.dart';
import 'package:mercle/features/onboarding/phoneverification.dart';
import 'package:mercle/features/onboarding/otpscreen.dart';
import 'package:mercle/features/onboarding/splashscreen.dart';
import 'package:mercle/features/onboarding/verification-success.dart';
import 'package:mercle/widgets/webview_face_liveness.dart';
import 'package:mercle/services/auth_service.dart';
import 'package:mercle/utils/face_verification_dialogs.dart';
import 'package:mercle/utils/verification_bottom_sheet.dart';
import 'package:mercle/widgets/web_face_liveness.dart';
import 'package:mercle/navbar.dart';
import 'package:flutter/foundation.dart';

Route<dynamic> routeSettings(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case SplashScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          return SplashScreen();
        },
      );
    case PhoneVerificationScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          return PhoneVerificationScreen();
        },
      );
    case OtpScreen.routeName:
      final args = routeSettings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          return OtpScreen(phoneNumber: args?['phoneNumber'] ?? '');
        },
      );
    case DeviceMockup.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          return DeviceMockup();
        },
      );
    case IdentityActiveScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          return IdentityActiveScreen();
        },
      );
    case FaceScanSetup.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          return FaceScanSetup();
        },
      );
    case '/navbar':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          return const NavBar();
        },
      );
    case '/face-verification':
      final args = routeSettings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          return FaceVerificationScreen(sessionId: args?['sessionId'] ?? '');
        },
      );
    case '/face-liveness-polling':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          // Use WebFaceLiveness for both web and mobile (web opens external, mobile shows message)
          return WebFaceLiveness(
            onResult: (result) async {
              Navigator.pop(context); // Close face scan screen
              
              // If face scan is complete, show under verification modal
              if (result['success'] == true && result['scanComplete'] == true) {
                // Pop back to FaceScanSetup screen first
                Navigator.pushReplacementNamed(context, FaceScanSetup.routeName);
                
                // Then show the under verification bottom sheet with sessionId after a brief delay
                Future.delayed(const Duration(milliseconds: 500), () {
                  showUnderVerificationBottomSheet(
                    context, 
                    sessionId: result['sessionId'],
                  );
                });
              } else {
                // Face scan failed - show retry dialog
                showFaceScanFailedDialog(context);
              }
            },
            onError: (error) {
              Navigator.pop(context);
              showVerificationError(context, error);
            },
            onCancel: () {
              Navigator.pop(context);
              showVerificationCancelledDialog(context);
            },
          );
        },
      );
    case '/face-liveness':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          return WebViewFaceLiveness(
            onResult: (result) {
              Navigator.pop(context);

              // Navigate based on verification result
              if (result.success && result.isLive) {
                // Success! Navigate to Identity Active screen
                Navigator.pushNamed(context, IdentityActiveScreen.routeName);
              } else {
                // Failure! Show bottom sheet with error details
                showModalBottomSheet(
                  context: context,
                  isDismissible: false,
                  enableDrag: false,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
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
                        padding: EdgeInsets.only(
                          top: 48.h,
                          left: 32.w,
                          right: 32.w,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Scan Failed',
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
                              'Your presence wasn’t clear. Adjust\nyour position and retry.',
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
                            SizedBox(height: 67.h),
                            Container(
                              height: 62.h,
                              width: 338.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24.r),
                                color: Color(0xffF5F5F5),
                              ),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'Face visible. No mask. No sunglasses.',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 22.27.sp,
                                        fontFamily: 'HandjetRegular',
                                        fontWeight: FontWeight.w400,
                                        height: 1.45,
                                        letterSpacing: -0.22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 52.h),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/face-liveness');
                              },
                              child: Container(
                                height: 52.h,
                                width: 161.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  'Try Again',
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
                      ),
                    );
                  },
                );
              }
            },
            onError: (error) {
              Navigator.pop(context);
              // Show bottom sheet for technical errors
              showModalBottomSheet(
                context: context,
                isDismissible: false,
                enableDrag: false,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_outlined,
                          color: Colors.orange,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Technical Error',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please check your connection and try again',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Close bottom sheet
                              Navigator.pushNamed(
                                context,
                                FaceScanSetup.routeName,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Try Again',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            onCancel: () {
              Navigator.pop(context);
              // Show bottom sheet for cancellation
              showModalBottomSheet(
                context: context,
                isDismissible: false,
                enableDrag: false,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cancel_outlined,
                          color: Colors.grey,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Verification Cancelled',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Face verification was cancelled',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You can start again when ready',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Close bottom sheet
                              Navigator.pushNamed(
                                context,
                                FaceScanSetup.routeName,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Start Over',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      );
    case '/verification-success':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          return const VerificationSuccessScreen();
        },
      );
    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder:
            (_) => const Scaffold(
              body: Center(child: Text('Screen does not exist!')),
            ),
      );
  }
}
