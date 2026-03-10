import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/app/routes/app_router.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/app/theme/app_theme.dart';
import 'package:sajilofix/app/theme/theme_mode_controller.dart';

class SajiloFix extends ConsumerWidget {
  const SajiloFix({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(appThemeModeProvider);

    return MaterialApp(
      title: "Sajilo Fix",
      theme: getSalijoFixAppTheme(),
      darkTheme: getSalijoFixDarkTheme(),
      themeMode: themeState.themeMode,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
