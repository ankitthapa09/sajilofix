import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sajilofix/screens/onboarding_screens/onboarding_screen.dart';
//import 'package:sajilofix/screens/signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text("Sajilo FIx"),
        //backgroundColor: Colors.blueAccent,
      ),
      // backgroundColor: Color(0xFFF9F9F9),
      body: SafeArea(
        child: Center(
          child: Image.asset(
            "assets/images/sajilofix_logo.png",
            width: 400,
            height: 400,
          ),
        ),
      ),
    );
  }
}
