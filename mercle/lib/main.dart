import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mercle/features/face-scan/screens/facescan-home.dart';
import 'package:provider/provider.dart';
import 'package:mercle/providers/user_provider.dart';
import 'package:mercle/router.dart';
import 'package:mercle/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: ScreenUtilInit(
        designSize: const Size(402, 874),
        builder: (_, child) {
          return MaterialApp(
            theme: ThemeData(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.iOS:
                      FadeUpwardsPageTransitionsBuilder(), // iOS style
                },
              ),
            ),
            debugShowCheckedModeBanner: false,
            onGenerateRoute: (settings) => routeSettings(settings),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
