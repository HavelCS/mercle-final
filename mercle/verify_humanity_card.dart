import 'package:flutter/material.dart';

class VerifyHumanityCard extends StatelessWidget {
  final VoidCallback? onStartFaceScan;

  const VerifyHumanityCard({
    Key? key,
    this.onStartFaceScan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Main card with stacked effect
          Stack(
            children: [
              // Background cards for stacked effect
              Positioned(
                top: 8,
                left: 4,
                right: 4,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                left: 2,
                right: 2,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              // Main card
              Container(
                height: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4A4A4A),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Verify humanity',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Description
                    const Text(
                      'Scanning your face creates a secure vault on the Mercle chain, your encrypted key to proving you\'re you, anywhere.',
                      style: TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 16,
                        height: 1.5,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    // Face scan area placeholder
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4A4A4A),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.face,
                          color: Color(0xFF666666),
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Instructions card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF3A3A3A),
                width: 1,
              ),
            ),
            child: const Text(
              'Face visible. No mask. No sunglasses.',
              style: TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          // Start Face Scan button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartFaceScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start Face Scan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

