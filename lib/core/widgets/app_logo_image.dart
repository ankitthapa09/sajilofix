import 'package:flutter/material.dart';

class AppLogoImage extends StatelessWidget {
  final double height;

  const AppLogoImage({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      isDark
          ? 'assets/images/sajilofix_logo_light.png'
          : 'assets/images/sajilofix_logo.png',
      height: height,
    );
  }
}
