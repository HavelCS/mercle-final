import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mercle/constants/colors.dart';
import 'package:mercle/features/face-scan/screens/facescan-home.dart';

class VerificationSuccessScreen extends StatefulWidget {
  const VerificationSuccessScreen({super.key});

  @override
  State<VerificationSuccessScreen> createState() =>
      _VerificationSuccessScreenState();
}

class _VerificationSuccessScreenState extends State<VerificationSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const FaceScanSetup();
            },
          ),
        );
      }
    });
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
              SizedBox(height: 192.h),
              Center(
                child: Container(
                  child: Image.asset("assets/images/thumbsup.png"),
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Device signature successfully created',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 44.sp,
                  fontFamily: 'HandjetRegular',
                  fontWeight: FontWeight.w400,
                  height: 1.13,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'This device is now your gateway to\nverified presence',
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
            ],
          ),
        ),
      ),
    );
  }
}
