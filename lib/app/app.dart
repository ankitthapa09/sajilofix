import 'package:flutter/material.dart';
import 'package:sajilofix/app/theme/app_theme.dart';
import 'package:sajilofix/features/splash/presentation/splash_page.dart';

class SajiloFix extends StatelessWidget {
  const SajiloFix({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sajilo Fix",
      theme: getSalijoFixAppTheme(),
      home: const SplashScreen(),
    );
  }
}
