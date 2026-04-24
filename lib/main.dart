import 'package:flutter/material.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:hair_connect/core/theme/app_theme.dart';
import 'package:hair_connect/features/auth/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hair_connect/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HairConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: AppColors.primary,
        body: const SplashPage(),
      ),
    );
  }
}
