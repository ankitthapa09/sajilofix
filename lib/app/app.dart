import 'package:flutter/material.dart';
import 'package:sajilofix/app/routes/app_router.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/app/theme/app_theme.dart';

class SajiloFix extends StatelessWidget {
  const SajiloFix({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sajilo Fix",
      theme: getSalijoFixAppTheme(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
