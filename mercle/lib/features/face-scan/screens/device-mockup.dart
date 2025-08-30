import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mercle/constants/colors.dart';
import 'package:mercle/navbar.dart';
import 'package:mercle/services/auth_service.dart';

class DeviceMockup extends StatefulWidget {
  static const String routeName = "/device-mockup";
  const DeviceMockup({super.key});

  @override
  State<DeviceMockup> createState() => _DeviceMockupState();
}

class _DeviceMockupState extends State<DeviceMockup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 34.w, right: 34.w, top: 70.h),
          child: Column(
            children: [
              Center(child: SvgPicture.asset("assets/images/logo.svg")),
              SizedBox(height: 68.h),
              Text(
                'Meet mKey',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 44.sp,
                  fontFamily: 'HandjetRegular',
                  fontWeight: FontWeight.w400,
                  height: 1.13,
                ),
              ),
              SizedBox(height: 27.h),
              Container(
                height: 286.h,
                width: 293.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/mkeymodel.png"),
                  ),
                  color: Color(0xff252525),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(width: 2, color: Color(0xff828282)),
                ),
              ),
              SizedBox(height: 27.h),
              Text(
                'A secure vault has been created and\nlinked to your presence. This device is\nyour personal proof of being human.\nOnly you can access it.',
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
              SizedBox(height: 112.h),
              InkWell(
                onTap: () async {
                  // Mark onboarding as complete
                  await AuthService.completeOnboarding();

                  // Navigate to main app and remove all previous routes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const NavBar()),
                    (route) => false, // Remove all previous routes
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
            ],
          ),
        ),
      ),
    );
  }
}
