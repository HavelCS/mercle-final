import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mercle/constants/colors.dart';

class UnderVerificationScreen extends StatefulWidget {
  const UnderVerificationScreen({super.key});

  @override
  State<UnderVerificationScreen> createState() =>
      _UnderVerificationScreenState();
}

class _UnderVerificationScreenState extends State<UnderVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 70.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(child: SvgPicture.asset("assets/images/logo.svg")),

              Container(
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
                        'We’ve put your scan under\nthe verification queue, this might take\nsome time, please check back later.',
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
                      Container(
                        height: 52.h,
                        width: 161.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Notify me',
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
                    ],
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
