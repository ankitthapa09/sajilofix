import 'package:flutter/material.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/features/auth/presentation/pages/forget_password/forget_password_screen.dart';
import 'package:sajilofix/features/auth/presentation/pages/forget_password/get_code_screen.dart';
import 'package:sajilofix/features/auth/presentation/pages/forget_password/resetpassword_screen.dart';
import 'package:sajilofix/features/auth/presentation/pages/admin/admin_login_page.dart';
import 'package:sajilofix/features/auth/presentation/pages/user/user_login_page.dart';
import 'package:sajilofix/features/auth/presentation/pages/signup_page.dart';
import 'package:sajilofix/features/dashboard/authority/presentation/pages/authority_dashboard_page.dart';
import 'package:sajilofix/features/dashboard/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/pages/dashboard_page.dart';
import 'package:sajilofix/features/onboarding/presentation/pages/onboarding_page1.dart';
import 'package:sajilofix/features/onboarding/presentation/pages/onboarding_page2.dart';
import 'package:sajilofix/features/onboarding/presentation/pages/onboarding_page3.dart';
import 'package:sajilofix/features/splash/presentation/splash_page.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case AppRoutes.onboarding1:
        return MaterialPageRoute(builder: (_) => const Onboarding1Screen());

      case AppRoutes.onboarding2:
        return MaterialPageRoute(builder: (_) => const Onboarding2Screen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const UserLoginScreen());

      case AppRoutes.adminLogin:
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());

      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case AppRoutes.otp:
        return MaterialPageRoute(builder: (_) => const GetcodeScreen());

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgetpasswordScreen());

      case AppRoutes.getCode:
        return MaterialPageRoute(builder: (_) => const GetcodeScreen());

      case AppRoutes.resetPassword:
        return MaterialPageRoute(builder: (_) => ResetPasswordScreen());

      case AppRoutes.dashboard:
        final args = settings.arguments;
        final initialIndex = (args is int) ? args : 0;
        return MaterialPageRoute(
          builder: (_) => CitizenDashboard(initialIndex: initialIndex),
        );

      case AppRoutes.adminDashboard:
        final args = settings.arguments;
        final initialIndex = (args is int) ? args : 0;
        return MaterialPageRoute(
          builder: (_) => AdminDashboard(initialIndex: initialIndex),
        );

      case AppRoutes.authorityDashboard:
        final args = settings.arguments;
        final initialIndex = (args is int) ? args : 0;
        return MaterialPageRoute(
          builder: (_) => AuthorityDashboard(initialIndex: initialIndex),
        );

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
