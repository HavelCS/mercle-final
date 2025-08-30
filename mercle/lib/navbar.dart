import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mercle/constants/colors.dart';
import 'package:mercle/features/mkey/screens/mkeyscreen.dart';
import 'package:mercle/features/rewards/screens/rewards.dart';
import 'package:mercle/features/vouch/screens/vouch.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int index = 0;
  List<Widget> screens = [MkeyScreen(), VouchScreen(), RewardsScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: screens[index],
      bottomNavigationBar: Container(
        height: 88.h,

        decoration: BoxDecoration(color: Color(0XFF1F1F1F)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 54.w, right: 54.w, top: 15.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          index = 0;
                        });
                      },
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            "assets/images/mkey.svg",
                            color:
                                index == 0
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.30),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'mKey',
                            style: TextStyle(
                              color:
                                  index == 0
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.30),
                              fontSize: 12.sp,
                              fontFamily: 'GeistRegular',
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                              letterSpacing: -0.12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          index = 1;
                        });
                      },
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            "assets/images/triangle.svg",
                            color:
                                index == 1
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.30),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Vouch',
                            style: TextStyle(
                              color:
                                  index == 1
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.30),
                              fontSize: 12.sp,
                              fontFamily: 'GeistRegular',
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                              letterSpacing: -0.12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          index = 2;
                        });
                      },
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            "assets/images/colorfilter.svg",
                            color:
                                index == 2
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.30),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Rewards',
                            style: TextStyle(
                              color:
                                  index == 2
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.30),
                              fontSize: 12.sp,
                              fontFamily: 'GeistRegular',
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                              letterSpacing: -0.12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
