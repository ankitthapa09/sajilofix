import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/core/services/storage/app_preferences.dart';

@immutable
class AppThemeState {
  final ThemeMode themeMode;
  final bool darkModeEnabled;

  const AppThemeState({required this.themeMode, required this.darkModeEnabled});

  AppThemeState copyWith({ThemeMode? themeMode, bool? darkModeEnabled}) {
    return AppThemeState(
      themeMode: themeMode ?? this.themeMode,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }
}

final appThemeModeProvider =
    StateNotifierProvider<AppThemeModeController, AppThemeState>(
      (ref) => AppThemeModeController(),
    );

class AppThemeModeController extends StateNotifier<AppThemeState> {
  AppThemeModeController()
    : super(
        const AppThemeState(themeMode: ThemeMode.light, darkModeEnabled: false),
      ) {
    _load();
  }

  Future<void> _load() async {
    final enabled = await AppPreferences.isDarkModeEnabled();
    state = state.copyWith(
      darkModeEnabled: enabled,
      themeMode: enabled ? ThemeMode.dark : ThemeMode.light,
    );
  }

  // Backward-compatible method name used by existing settings pages.
  Future<void> setAutoDarkMode(bool enabled) async {
    await setDarkModeEnabled(enabled);
  }

  Future<void> setDarkModeEnabled(bool enabled) async {
    state = state.copyWith(
      themeMode: enabled ? ThemeMode.dark : ThemeMode.light,
      darkModeEnabled: enabled,
    );
    await AppPreferences.setDarkModeEnabled(enabled);
  }
}
