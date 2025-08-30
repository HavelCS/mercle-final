import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/auth_service.dart';

// Face Liveness Result Model
class FaceLivenessResult {
  final bool success;
  final bool isLive;
  final double confidence;
  final String message;
  final String? sessionId;
  final Map<String, dynamic>? fullResult;

  FaceLivenessResult({
    required this.success,
    required this.isLive,
    required this.confidence,
    required this.message,
    this.sessionId,
    this.fullResult,
  });

  factory FaceLivenessResult.fromJson(Map<String, dynamic> json) {
    return FaceLivenessResult(
      success: json['success'] ?? false,
      isLive: json['isLive'] ?? false,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      message: json['message'] ?? 'Unknown result',
      sessionId: json['sessionId'],
      fullResult: json['fullResult'],
    );
  }
}

class WebViewFaceLiveness extends StatefulWidget {
  final Function(FaceLivenessResult result)? onResult;
  final Function(String error)? onError;
  final VoidCallback? onCancel;
  final String? sessionId;

  const WebViewFaceLiveness({
    super.key,
    this.onResult,
    this.onError,
    this.onCancel,
    this.sessionId,
  });

  @override
  State<WebViewFaceLiveness> createState() => _WebViewFaceLivenessState();
}

class _WebViewFaceLivenessState extends State<WebViewFaceLiveness> {
  WebViewController? controller;
  bool isLoading = true;
  String? error;
  Timer? _timeoutTimer;

  // Your deployed React Face Liveness app URL
  static const String _faceLivenessUrl =
      'https://face-liveness-react-qdq4tm1t5.vercel.app';
  
  String _faceLivenessUrlWithToken = '';
  bool _urlInitialized = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
    _initializeUrlWithToken();
    _startTimeout();
  }
  
  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }
  
  void _startTimeout() {
    // Set a 60 second timeout for face liveness
    _timeoutTimer = Timer(const Duration(seconds: 60), () {
      if (mounted && isLoading) {
        setState(() {
          error = 'Face liveness timed out. Please try again.';
          isLoading = false;
        });
        if (widget.onError != null) {
          widget.onError!('Face liveness timed out. Please try again.');
        }
      }
    });
  }

  /// Initialize URL with authentication token and sessionId
  Future<void> _initializeUrlWithToken() async {
    try {
      final token = await AuthService.getToken();
      final sessionId = widget.sessionId;
      
      if (token != null && sessionId != null) {
        _faceLivenessUrlWithToken = '$_faceLivenessUrl?token=${Uri.encodeComponent(token)}&sessionId=${Uri.encodeComponent(sessionId)}';
        print('🔑 Face liveness URL with token and sessionId initialized');
      } else if (token != null) {
        _faceLivenessUrlWithToken = '$_faceLivenessUrl?token=${Uri.encodeComponent(token)}';
        print('🔑 Face liveness URL with token initialized (no sessionId)');
      } else {
        _faceLivenessUrlWithToken = _faceLivenessUrl;
        print('⚠️ No auth token available, using URL without token');
      }
      _urlInitialized = true;
      _initializeWebView();
    } catch (e) {
      print('❌ Error initializing URL with token: $e');
      _faceLivenessUrlWithToken = _faceLivenessUrl;
      _urlInitialized = true;
      _initializeWebView();
    }
  }

  Future<void> _requestCameraPermission() async {
    // Skip permission request on macOS as it's handled by entitlements
    // and will show system dialog automatically when camera is accessed
    try {
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Camera permission is required for face liveness detection',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Permission handler not available on macOS, skip
      print('⚠️ Permission handler not available on this platform: $e');
    }
  }

  void _initializeWebView() {
    if (!_urlInitialized) return; // Wait for URL to be initialized
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    
    // Set background color only on supported platforms
    try {
      controller!.setBackgroundColor(const Color(0xFF1a1a1a));
    } catch (e) {
      print('⚠️ Background color not supported on this platform: $e');
    }
    
    controller!
      ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Update loading progress if needed
              },
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() {
                    isLoading = true;
                    error = null;
                  });
                }
              },
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
                // Set up result listener with JavaScript
                _setupResultListener();
              },
              onHttpError: (HttpResponseError error) {
                if (mounted) {
                  setState(() {
                    this.error = 'HTTP Error: ${error.response?.statusCode}';
                    isLoading = false;
                  });
                }
              },
              onWebResourceError: (WebResourceError error) {
                if (mounted) {
                  setState(() {
                    this.error = 'Connection Error: ${error.description}';
                    isLoading = false;
                  });
                }
              },
            ),
          )
      ..addJavaScriptChannel(
            'flutterFaceLiveness',
            onMessageReceived: (JavaScriptMessage message) {
              _handleMessageFromReact(message.message);
            },
          )
      ..loadRequest(Uri.parse(_urlInitialized ? _faceLivenessUrlWithToken : _faceLivenessUrl));
  }

  /// Set up JavaScript listener for Face Liveness results
  void _setupResultListener() {
    if (controller == null) return;
    
    // Inject JavaScript to set up a listener for results
    controller!.runJavaScript('''
      console.log('🔧 Setting up Flutter communication...');
      
      // Ensure flutterFaceLiveness is available
      if (!window.flutterFaceLiveness) {
        console.error('❌ flutterFaceLiveness channel not available!');
      } else {
        console.log('✅ flutterFaceLiveness channel is available');
      }
      
      window.addEventListener('message', function(event) {
        console.log('📨 Received postMessage:', event.data);
        if (event.data && typeof event.data === 'string') {
          try {
            const data = JSON.parse(event.data);
            console.log('📊 Parsed message data:', data);
            if (data.type && (data.type === 'FACE_LIVENESS_RESULT' || data.type === 'FACE_LIVENESS_ERROR' || data.type === 'FACE_LIVENESS_CANCEL')) {
              // Forward the result to Flutter
              console.log('📤 Forwarding to Flutter:', data);
              if (window.flutterFaceLiveness) {
                window.flutterFaceLiveness.postMessage(JSON.stringify(data));
              } else {
                console.error('❌ Cannot forward to Flutter: channel not available');
              }
            }
          } catch (e) {
            console.error('❌ Error parsing message:', e);
          }
        }
      });
      
      // Set up a global variable to receive results from React component
      window.sendResultToFlutter = function(result) {
        console.log('📤 sendResultToFlutter called with:', result);
        try {
          const messageData = {
            type: 'FACE_LIVENESS_RESULT',
            ...result
          };
          console.log('📤 Sending via sendResultToFlutter:', messageData);
          if (window.flutterFaceLiveness) {
            window.flutterFaceLiveness.postMessage(JSON.stringify(messageData));
          } else {
            console.error('❌ flutterFaceLiveness channel not available for sendResultToFlutter');
          }
        } catch (e) {
          console.error('❌ Error in sendResultToFlutter:', e);
        }
      };
      
      // Test function to verify communication
      window.testFlutterCommunication = function() {
        console.log('🧪 Testing Flutter communication...');
        if (window.flutterFaceLiveness) {
          window.flutterFaceLiveness.postMessage(JSON.stringify({
            type: 'FACE_LIVENESS_RESULT',
            success: true,
            isLive: true,
            confidence: 0.95,
            message: 'Test message from JavaScript',
            sessionId: 'test'
          }));
        } else {
          console.error('❌ Cannot test: flutterFaceLiveness channel not available');
        }
      };
      
      console.log('✅ Flutter result listener initialized');
    ''');
  }

  /// Handle messages from React app
  void _handleMessageFromReact(String message) {
    try {
      print('📨 Received message from React: $message');
      
      // Validate message is not empty
      if (message.isEmpty) {
        print('⚠️ Empty message received from React');
        return;
      }
      
      final Map<String, dynamic> data = json.decode(message);
      print('📊 Parsed message data: $data');

      if (data['type'] == 'FACE_LIVENESS_RESULT') {
        print('✅ Processing Face Liveness result');
        
        // Cancel timeout since we received a result
        _timeoutTimer?.cancel();
        
        // Convert to FaceLivenessResult and notify
        final result = FaceLivenessResult.fromJson(data);
        print('📋 Converted result: success=${result.success}, isLive=${result.isLive}, confidence=${result.confidence}');

        if (widget.onResult != null) {
          widget.onResult!(result);
        }

        // Close WebView after result
        if (mounted && result.success) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
        }
      } else if (data['type'] == 'FACE_LIVENESS_ERROR') {
        print('❌ Processing Face Liveness error: ${data['message']}');
        if (widget.onError != null) {
          widget.onError!(data['message'] ?? 'Unknown error');
        }
      } else if (data['type'] == 'FACE_LIVENESS_CANCEL') {
        print('🚫 Processing Face Liveness cancel');
        if (widget.onCancel != null) {
          widget.onCancel!();
        }
      } else {
        print('⚠️ Unknown message type: ${data['type']}');
      }
    } catch (e, stackTrace) {
      print('❌ Error handling message from React: $e');
      print('📍 Stack trace: $stackTrace');
      print('📨 Original message: $message');
      
      // Try to determine the specific error
      String errorMessage = 'Failed to process face liveness result';
      if (e is FormatException) {
        errorMessage = 'Invalid message format from face liveness';
        print('🔍 Format error details: ${e.message}');
      } else if (e.toString().contains('type')) {
        errorMessage = 'Missing message type in face liveness response';
      }
      
      if (widget.onError != null) {
        widget.onError!(errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // WebView fills entire body
          if (controller != null) WebViewWidget(controller: controller!),
          if (!isLoading && error == null)
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
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading Face Liveness...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Error overlay
          if (error != null)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Connection Error',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              error = null;
                            });
                            _initializeWebView();
                          },
                          child: const Text('Try Again'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: widget.onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
