import 'package:flutter/material.dart';
import 'package:mercle/services/auth_service.dart';
import 'package:mercle/features/onboarding/phoneverification.dart';
import 'package:mercle/features/face-scan/screens/facescan-home.dart';
import 'package:mercle/features/face-scan/screens/identity-active.dart';
import 'package:mercle/features/onboarding/splashscreen.dart';
import 'package:mercle/navbar.dart';
import 'package:provider/provider.dart';
import 'package:mercle/providers/user_provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _isOnboardingComplete = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }
  
  void _setupJobMonitoring() {
    // Only set up job monitoring if user is authenticated but not onboarded
    if (!_isAuthenticated || _isOnboardingComplete) {
      print('🚫 Skipping job monitoring setup - user not authenticated or already onboarded');
      return;
    }
    
    print('🔄 Setting up job monitoring for authenticated user needing face verification');
    
    // Set up job monitoring with navigation callbacks after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      userProvider.initializeJobMonitoring(
        onNavigateToIdentity: () {
          // Navigate to identity-active screen when verification is successful
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(IdentityActiveScreen.routeName);
          }
        },
        onNavigateToFaceScanWithError: (String errorMessage) {
          // Navigate back to face scan setup with error snackbar
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(FaceScanSetup.routeName);
            
            // Show error snackbar after navigation
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            });
          }
        },
      );
    });
  }
  
  void _stopJobMonitoring() {
    print('⏹️ Stopping job monitoring');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.stopJobMonitoring();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isAuthenticated = await AuthService.isAuthenticated();
      final isOnboardingComplete = await AuthService.isOnboardingComplete();

      if (isAuthenticated) {
        // Verify token is still valid and get user data
        final userResult = await AuthService.getCurrentUser();
        final tokenValid =
            userResult['success'] && !userResult.containsKey('requiresAuth');

        if (tokenValid) {
          // Check user verification status
          final userData = userResult['user'];
          final userStatus = userData['status'] ?? 'new';
          
          print('👤 User status on app restart: $userStatus');
          
          // If user status is 'verified', they should go to main app regardless of onboarding flag
          final shouldShowMainApp = userStatus == 'verified' || isOnboardingComplete;
          
          setState(() {
            _isAuthenticated = true;
            _isOnboardingComplete = shouldShowMainApp;
            _isLoading = false;
          });
          
          // If user is verified but onboarding flag wasn't set, set it now
          if (userStatus == 'verified' && !isOnboardingComplete) {
            print('✅ User is verified, marking onboarding as complete');
            await AuthService.completeOnboarding();
          }
        } else {
          // Token invalid
          setState(() {
            _isAuthenticated = false;
            _isOnboardingComplete = false;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isAuthenticated = false;
          _isOnboardingComplete = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error checking auth status: $e');
      setState(() {
        _isAuthenticated = false;
        _isOnboardingComplete = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen(); // Show splash while checking auth
    }

    if (_isAuthenticated && _isOnboardingComplete) {
      // User completed everything, stop job monitoring and go to main app
      _stopJobMonitoring();
      return const NavBar();
    } else if (_isAuthenticated) {
      // User is authenticated but needs face scan - start job monitoring
      _setupJobMonitoring();
      return const FaceScanSetup();
    } else {
      // User needs to authenticate - stop job monitoring
      _stopJobMonitoring();
      return const PhoneVerificationScreen();
    }
  }
}
