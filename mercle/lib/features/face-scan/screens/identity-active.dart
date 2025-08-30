import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mercle/features/face-scan/screens/device-mockup.dart';

class IdentityActiveScreen extends StatefulWidget {
  static const String routeName = '/identity-active';
  const IdentityActiveScreen({super.key});

  @override
  State<IdentityActiveScreen> createState() => _IdentityActiveScreenState();
}

class _IdentityActiveScreenState extends State<IdentityActiveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 70.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: SvgPicture.asset(
                  "assets/images/logo.svg",
                  colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                ),
              ),
        
              Container(
                height: 462.h,
                width: 402.w,
                decoration: BoxDecoration(color: Colors.black),
                child: Padding(
                  padding: EdgeInsets.only(),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 10.h,
                            width: 101.w,
                            decoration: BoxDecoration(color: Color(0xff51EC74)),
                          ),
                          Container(
                            height: 10.h,
                            width: 100.w,
                            decoration: BoxDecoration(color: Color(0xffFBDA64)),
                          ),
                          Container(
                            height: 10.h,
                            width: 100.w,
                            decoration: BoxDecoration(color: Color(0xffFF555A)),
                          ),
                          Container(
                            height: 10.h,
                            width: 101.w,
                            decoration: BoxDecoration(color: Color(0xff7183FF)),
                          ),
                        ],
                      ),
                      Container(
                        height: 72.h,
                        width: 293.w,
                        decoration: BoxDecoration(
                          color: Color(0xff252525),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12.r),
                            bottomRight: Radius.circular(12.r),
                          ),
                          border: Border.all(
                            width: 2.w,
                            color: Color(0xff828282),
                          ),
                        ),
                      ),
                      SizedBox(height: 44.h),
                      Text(
                        'Your identity is\nnow active',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44.sp,
                          fontFamily: 'HandjetRegular',
                          fontWeight: FontWeight.w400,
                          height: 1.13,
                        ),
                      ),
                      SizedBox(height: 87.h),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, DeviceMockup.routeName);
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
                            'Next',
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
            ],
          ),
        ),
      ),
    );
  }
}
