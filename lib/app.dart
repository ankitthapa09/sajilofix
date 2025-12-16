import 'package:flutter/material.dart';
import 'package:sajilofix/screens/citizen_dashboard.dart';
import 'package:sajilofix/screens/splash_screen.dart';
import 'package:sajilofix/theme/sajilofix_theme_data.dart';

class SajiloFix extends StatelessWidget {
  const SajiloFix({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sajilo Fix",
      theme: getSalijoFixAppTheme(),
      home: CitizenDashboard(),
    );
  }
}
