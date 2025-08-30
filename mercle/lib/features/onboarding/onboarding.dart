import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mercle/constants/colors.dart';
import 'package:mercle/features/onboarding/phoneverification.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            /// Background colored stripes
            SizedBox(
              width: double.infinity,
              height: 337.h,
              child: Row(
                children: [
                  Container(width: 100.5.w, color: const Color(0xff51EC74)),
                  Container(width: 100.5.w, color: const Color(0xffFBDA64)),
                  Container(width: 100.5.w, color: const Color(0xffFF555A)),
                  Container(width: 100.5.w, color: const Color(0xff7183FF)),
                ],
              ),
            ),

            /// Dot-art overlay (put this BEFORE column so text is on top)
            Positioned(
              left: 100,
              top: 250,
              child: Image.asset("assets/images/dot-art.png"),
            ),

            /// Foreground content (centered)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 350.h),
                Text(
                  'Welcome to your\nhuman space',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44.sp,
                    fontFamily: 'HandjetRegular',
                    fontWeight: FontWeight.w400,
                    height: 1.13,
                  ),
                ),

                SizedBox(height: 10.h),

                Text(
                  'Turn your face into a proof of\npersonhood ID for the internet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: 16.sp,
                    fontFamily: 'GeistRegular',
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    letterSpacing: -0.16,
                  ),
                ),

                SizedBox(height: 50.h),

                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        PhoneVerificationScreen.routeName,
                      );
                    },
                    child: Container(
                      height: 54.h,
                      width: 161.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Get Started',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF040414),
                          fontSize: 16,
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w400,
                          height: 1.12,
                        ),
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
