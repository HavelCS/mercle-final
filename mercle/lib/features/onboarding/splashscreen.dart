import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mercle/constants/colors.dart';
import 'package:mercle/features/onboarding/onboarding.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "/splash-screen";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
        );
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(child: SvgPicture.asset("assets/images/logo.svg")),
    );
  }
}
