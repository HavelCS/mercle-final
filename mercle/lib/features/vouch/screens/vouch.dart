import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mercle/common/custom-appbar.dart';
import 'package:mercle/constants/colors.dart';
import 'dart:ui' as ui;

import 'package:mercle/constants/utils.dart';

class VouchScreen extends StatefulWidget {
  const VouchScreen({super.key});

  @override
  State<VouchScreen> createState() => _VouchScreenState();
}

class _VouchScreenState extends State<VouchScreen> {
  String code = "CY23OP";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(),

            SizedBox(height: 20.h),
            Divider(height: 1, color: Color(0xff888888)),
            SizedBox(height: 50.h),
            Text(
              'Vouch for Humanity',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 44.sp,
                fontFamily: 'HandjetRegular',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Invite your friends to vouch or get\nvouched. Every vouch strengthens\nyour Humanity Score!',
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
            SizedBox(height: 51.h),
            Stack(
              children: [
                CustomPaint(size: Size(304, 450), painter: RPSCustomPainter()),
                Positioned(
                  top: 40,
                  left: 40,
                  child: Column(
                    children: [
                      Text(
                        'Real Ones Only',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44.sp,
                          fontFamily: 'HandjetRegular',
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      Text(
                        'A real invite for real humans',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF6C6C6C),
                          fontSize: 16.sp,
                          fontFamily: 'GeistRegular',
                          fontWeight: FontWeight.w400,

                          letterSpacing: -0.16,
                        ),
                      ),
                      SizedBox(height: 38.h),
                      Container(
                        height: 48.h,
                        width: 155.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Color(0xff888888),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              code,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19.01.sp,
                                fontFamily: 'GeistRegular',
                                fontWeight: FontWeight.w300,
                                height: 1.45,
                                letterSpacing: 4.18,
                              ),
                            ),
                            SizedBox(width: 9.w),
                            InkWell(
                              onTap: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: code),
                                );
                                showSnackBar(context, "Copied");
                                // copied successfully
                              },
                              child: SvgPicture.asset("assets/images/copy.svg"),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 38.h),
                      Container(
                        height: 54.h,
                        width: 161.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Share an invite',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF040414),
                            fontSize: 16.sp,
                            fontFamily: 'GeistRegular',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 38.h),
                      Text(
                        '+3 points for every connection',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontFamily: 'HandjetRegular',
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                          letterSpacing: -0.20,
                        ),
                      ),
                    ],
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

//Add this CustomPaint widget to the Widget Tree

//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(103.258, 0);
    path_0.cubicTo(105.758, 24.16, 126.179, 43, 151, 43);
    path_0.cubicTo(175.821, 43, 196.242, 24.16, 198.742, 0);
    path_0.lineTo(304, 0);
    path_0.lineTo(304, 450);
    path_0.lineTo(198.157, 450);
    path_0.cubicTo(193.945, 427.792, 174.433, 411, 151, 411);
    path_0.cubicTo(127.567, 411, 108.055, 427.792, 103.843, 450);
    path_0.lineTo(0, 450);
    path_0.lineTo(0, 0);
    path_0.lineTo(103.258, 0);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);

    Path path_1 = Path();
    path_1.moveTo(103.258, 0);
    path_1.cubicTo(105.758, 24.16, 126.179, 43, 151, 43);
    path_1.cubicTo(175.821, 43, 196.242, 24.16, 198.742, 0);
    path_1.lineTo(304, 0);
    path_1.lineTo(304, 450);
    path_1.lineTo(198.157, 450);
    path_1.cubicTo(193.945, 427.792, 174.433, 411, 151, 411);
    path_1.cubicTo(127.567, 411, 108.055, 427.792, 103.843, 450);
    path_1.lineTo(0, 450);
    path_1.lineTo(0, 0);
    path_1.lineTo(103.258, 0);
    path_1.close();

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = Colors.black.withOpacity(1.0);
    canvas.drawPath(path_1, paint_1_fill);

    Path path_2 = Path();
    path_2.moveTo(103.258, 0);
    path_2.lineTo(104.252, -0.102953);
    path_2.lineTo(104.16, -1);
    path_2.lineTo(103.258, -1);
    path_2.lineTo(103.258, 0);
    path_2.close();
    path_2.moveTo(198.742, 0);
    path_2.lineTo(198.742, -1);
    path_2.lineTo(197.84, -1);
    path_2.lineTo(197.748, -0.102953);
    path_2.lineTo(198.742, 0);
    path_2.close();
    path_2.moveTo(304, 0);
    path_2.lineTo(305, 0);
    path_2.lineTo(305, -1);
    path_2.lineTo(304, -1);
    path_2.lineTo(304, 0);
    path_2.close();
    path_2.moveTo(304, 450);
    path_2.lineTo(304, 451);
    path_2.lineTo(305, 451);
    path_2.lineTo(305, 450);
    path_2.lineTo(304, 450);
    path_2.close();
    path_2.moveTo(198.157, 450);
    path_2.lineTo(197.175, 450.186);
    path_2.lineTo(197.329, 451);
    path_2.lineTo(198.157, 451);
    path_2.lineTo(198.157, 450);
    path_2.close();
    path_2.moveTo(103.843, 450);
    path_2.lineTo(103.843, 451);
    path_2.lineTo(104.671, 451);
    path_2.lineTo(104.825, 450.186);
    path_2.lineTo(103.843, 450);
    path_2.close();
    path_2.moveTo(0, 450);
    path_2.lineTo(-1, 450);
    path_2.lineTo(-1, 451);
    path_2.lineTo(0, 451);
    path_2.lineTo(0, 450);
    path_2.close();
    path_2.moveTo(0, 0);
    path_2.lineTo(0, -1);
    path_2.lineTo(-1, -1);
    path_2.lineTo(-1, 0);
    path_2.lineTo(0, 0);
    path_2.close();
    path_2.moveTo(103.258, 0);
    path_2.lineTo(102.263, 0.102953);
    path_2.cubicTo(104.816, 24.7673, 125.661, 44, 151, 44);
    path_2.lineTo(151, 43);
    path_2.lineTo(151, 42);
    path_2.cubicTo(126.697, 42, 106.701, 23.5526, 104.252, -0.102953);
    path_2.lineTo(103.258, 0);
    path_2.close();
    path_2.moveTo(151, 43);
    path_2.lineTo(151, 44);
    path_2.cubicTo(176.339, 44, 197.184, 24.7673, 199.737, 0.102953);
    path_2.lineTo(198.742, 0);
    path_2.lineTo(197.748, -0.102953);
    path_2.cubicTo(195.299, 23.5526, 175.303, 42, 151, 42);
    path_2.lineTo(151, 43);
    path_2.close();
    path_2.moveTo(198.742, 0);
    path_2.lineTo(198.742, 1);
    path_2.lineTo(304, 1);
    path_2.lineTo(304, 0);
    path_2.lineTo(304, -1);
    path_2.lineTo(198.742, -1);
    path_2.lineTo(198.742, 0);
    path_2.close();
    path_2.moveTo(304, 0);
    path_2.lineTo(303, 0);
    path_2.lineTo(303, 450);
    path_2.lineTo(304, 450);
    path_2.lineTo(305, 450);
    path_2.lineTo(305, 0);
    path_2.lineTo(304, 0);
    path_2.close();
    path_2.moveTo(304, 450);
    path_2.lineTo(304, 449);
    path_2.lineTo(198.157, 449);
    path_2.lineTo(198.157, 450);
    path_2.lineTo(198.157, 451);
    path_2.lineTo(304, 451);
    path_2.lineTo(304, 450);
    path_2.close();
    path_2.moveTo(198.157, 450);
    path_2.lineTo(199.14, 449.814);
    path_2.cubicTo(194.839, 427.143, 174.923, 410, 151, 410);
    path_2.lineTo(151, 411);
    path_2.lineTo(151, 412);
    path_2.cubicTo(173.944, 412, 193.05, 428.442, 197.175, 450.186);
    path_2.lineTo(198.157, 450);
    path_2.close();
    path_2.moveTo(151, 411);
    path_2.lineTo(151, 410);
    path_2.cubicTo(127.077, 410, 107.161, 427.143, 102.86, 449.814);
    path_2.lineTo(103.843, 450);
    path_2.lineTo(104.825, 450.186);
    path_2.cubicTo(108.95, 428.442, 128.056, 412, 151, 412);
    path_2.lineTo(151, 411);
    path_2.close();
    path_2.moveTo(103.843, 450);
    path_2.lineTo(103.843, 449);
    path_2.lineTo(0, 449);
    path_2.lineTo(0, 450);
    path_2.lineTo(0, 451);
    path_2.lineTo(103.843, 451);
    path_2.lineTo(103.843, 450);
    path_2.close();
    path_2.moveTo(0, 450);
    path_2.lineTo(1, 450);
    path_2.lineTo(1, 0);
    path_2.lineTo(0, 0);
    path_2.lineTo(-1, 0);
    path_2.lineTo(-1, 450);
    path_2.lineTo(0, 450);
    path_2.close();
    path_2.moveTo(0, 0);
    path_2.lineTo(0, 1);
    path_2.lineTo(103.258, 1);
    path_2.lineTo(103.258, 0);
    path_2.lineTo(103.258, -1);
    path_2.lineTo(0, -1);
    path_2.lineTo(0, 0);
    path_2.close();

    Paint paint_2_fill = Paint()..style = PaintingStyle.fill;
    paint_2_fill.color = Color(0xff888888).withOpacity(1.0);
    canvas.drawPath(path_2, paint_2_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
