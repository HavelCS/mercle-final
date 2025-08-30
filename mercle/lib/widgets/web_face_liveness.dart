import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class WebFaceLiveness extends StatefulWidget {
  final Function(Map<String, dynamic> result)? onResult;
  final Function(String error)? onError;
  final VoidCallback? onCancel;

  const WebFaceLiveness({
    super.key,
    this.onResult,
    this.onError,
    this.onCancel,
  });

  @override
  State<WebFaceLiveness> createState() => _WebFaceLivenessState();
}

class _WebFaceLivenessState extends State<WebFaceLiveness> {
  bool isLoading = false;
  String? error;
  String? sessionId;

  // Your deployed React Face Liveness app URL
  static const String _faceLivenessUrl =
      'https://face-liveness-react-pvktmdl76.vercel.app';

  @override
  void initState() {
    super.initState();
    // Generate session ID and start the scanning flow
    _initiateFaceScan();
  }

  void _initiateFaceScan() async {
    // Generate unique session ID
    sessionId =
        'flutter-web-${DateTime.now().millisecondsSinceEpoch}-${(DateTime.now().microsecond % 1000)}';

    setState(() {
      isLoading = false; // Not loading initially, waiting for user action
    });
  }

  void _startPollingForResults() async {
    if (sessionId == null) return;

    setState(() {
      isLoading = true;
    });

    // Poll for results every 3 seconds for up to 5 minutes
    int attempts = 0;
    const maxAttempts = 100; // 5 minutes with 3-second intervals

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 3));
      attempts++;

      // TODO: Replace this with actual API call to check session status
      // For now, simulate completion after 15 seconds (5 attempts)
      if (attempts >= 5) {
        setState(() {
          isLoading = false;
        });

        if (widget.onResult != null) {
          widget.onResult!({
            'success': true,
            'isLive': true,
            'confidence': 0.95,
            'message': 'Face scan captured successfully',
            'sessionId': sessionId!,
            'scanComplete': true,
          });
        }
        return;
      }
    }

    // Timeout after 5 minutes
    setState(() {
      isLoading = false;
    });

    if (widget.onError != null) {
      widget.onError!('Face scan timed out. Please try again.');
    }
  }

  void _openFaceLivenessInNewTab() async {
    if (sessionId == null) return;

    // Construct URL with session ID
    final urlWithSession = '$_faceLivenessUrl?sessionId=$sessionId';

    if (await canLaunchUrl(Uri.parse(urlWithSession))) {
      await launchUrl(
        Uri.parse(urlWithSession),
        mode: LaunchMode.externalApplication,
      );

      // Start polling for results after opening the external app
      _startPollingForResults();
    } else {
      if (widget.onError != null) {
        widget.onError!('Could not open face scanning app');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: Stack(
        children: [
          // Background with face scanning interface
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withValues(alpha: 0.3),
                        Colors.purple.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.face_retouching_natural,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  kIsWeb ? 'Face Scan - Web Testing' : 'Face Scan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Session ID display
                if (sessionId != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Session ID:',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sessionId!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Courier',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (kIsWeb && !isLoading) ...[
                  ElevatedButton.icon(
                    onPressed: _openFaceLivenessInNewTab,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Start Face Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'This will open the face scanning app\nin a new tab with your session ID',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ] else if (!kIsWeb) ...[
                  const Text(
                    'Face scanning available on web only',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],

                if (isLoading) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Scan in progress...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete the scan in the opened tab',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Waiting for Face Scan...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Complete the scan in the opened browser tab',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Session: ${sessionId ?? 'Loading...'}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Web testing badge
          if (kIsWeb && !isLoading)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '🌐 Flutter Web Testing',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
