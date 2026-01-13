import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
//import 'package:sajilofix/screens/signup_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 4), _routeFromSplash);
  }

  Future<void> _routeFromSplash() async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
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
