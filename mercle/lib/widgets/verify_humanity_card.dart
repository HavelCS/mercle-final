import 'package:flutter/material.dart';

class Frame3658 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 338,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 268.46,
                height: 308.61,
                decoration: ShapeDecoration(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.80),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Container(
                width: 268.46,
                height: 308.61,
                decoration: ShapeDecoration(
                  color: const Color(0x7F333333),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.80),
                  ),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: 220.44,
                height: 72.69,
                child: Text(
                  'Scanning your face creates a secure vault on the Mercle chain, your encrypted key to proving you\'re human, anywhere.',
                  style: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: 13.86,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    letterSpacing: -0.14,
                  ),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: 189.90,
                height: 45.43,
                child: Text(
                  'Verify humanity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38.12,
                    fontFamily: 'Instrument Serif',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Container(
                transform:
                    Matrix4.identity()
                      ..translate(0.0, 0.0)
                      ..rotateZ(0.04),
                width: 295.47,
                height: 339.66,
                decoration: ShapeDecoration(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.80),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Container(
                transform:
                    Matrix4.identity()
                      ..translate(0.0, 0.0)
                      ..rotateZ(0.04),
                width: 295.47,
                height: 339.66,
                decoration: ShapeDecoration(
                  color: const Color(0x7F4F4F4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.80),
                  ),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: 242.61,
                child: Text(
                  'Scanning your face creates a secure vault on the Mercle chain, your encrypted key to proving you\'re human, anywhere.',
                  style: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: 13.86,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    letterSpacing: -0.14,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Verify humanity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38.12,
                  fontFamily: 'Instrument Serif',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 24),
              Container(
                width: 336,
                height: 390,
                decoration: ShapeDecoration(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23.79),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Container(
                width: 336,
                height: 390,
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.50, -0.00),
                    end: Alignment(0.50, 1.00),
                    colors: [const Color(0xFF272E2D), const Color(0xFF404040)],
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Container(
                width: 247.27,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 247.27,
                      child: Text(
                        'Verify humanity',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 43.61,
                          fontFamily: 'Handjet',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: 247.27,
                      child: Text(
                        'Scanning your face creates a secure vault on the Mercle chain, your encrypted key to proving you\'re you, anywhere.',
                        style: TextStyle(
                          color: const Color(0xFFA1A1A1),
                          fontSize: 15.86,
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                          letterSpacing: -0.16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 33,
                  vertical: 28,
                ),
                decoration: ShapeDecoration(
                  color: const Color(0x66444444),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Face visible. No mask. No sunglasses.',
                      style: TextStyle(
                        color: const Color(0xFFCCCCCC),
                        fontSize: 22.27,
                        fontFamily: 'Handjet',
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                        letterSpacing: -0.22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
