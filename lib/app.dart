import 'package:flutter/material.dart';
import 'package:sajilofix/splash_screen.dart';

class SajiloFix extends StatelessWidget {
  const SajiloFix({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sajilo Fix",
      theme: ThemeData(fontFamily: "Poppins"),
      home: SplashScreen(),
    );
  }
}
