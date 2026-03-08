import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/core/widgets/gradiant_elevated_button.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/constants/hero_tags.dart';
import 'package:sajilofix/core/services/biometrics/biometric_service.dart';
import 'package:sajilofix/core/services/storage/app_preferences.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/notifications/presentation/providers/notification_providers.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  bool showPassword = false;

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPassController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  bool _isAdminEmail(String email) {
    return email.trim().toLowerCase() == 'admin@sajilofix.com';
  }

  String? _validateAdminEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter email';
    if (!v.contains('@')) return 'Please enter valid email';

    if (!_isAdminEmail(v)) {
      return 'Admin login requires admin@sajilofix.com';
    }

    return null;
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPassController.dispose();
    super.dispose();
  }

  Future<bool> _requireBiometric() async {
    final enabled = await AppPreferences.isBiometricEnabled(roleIndex: 1);
    if (!enabled) return true;

    final service = BiometricService();
    final available = await service.isAvailable();
    if (!available) {
      showMySnackBar(
        context: context,
        message: 'Biometric is not available on this device.',
        isError: true,
      );
      return true;
    }

    final ok = await service.authenticate(
      reason: 'Confirm to finish signing in',
    );
    if (!ok) {
      await ref.read(authRepositoryProvider).logout();
      ref.invalidate(currentUserProvider);
      showMySnackBar(
        context: context,
        message: 'Biometric authentication failed.',
        isError: true,
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Hero(
                  tag: HeroTags.appLogo,
                  child: Image.asset(
                    'assets/images/sajilofix_logo.png',
                    height: 120,
                  ),
                ),
                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Admin Login',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('Email', style: theme.textTheme.labelLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _loginEmailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'admin@sajilofix.com',
                        ),
                        validator: _validateAdminEmail,
                      ),

                      const SizedBox(height: 14),
                      Text('Password', style: theme.textTheme.labelLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _loginPassController,
                        obscureText: !showPassword,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: 'Enter your password',
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => showPassword = !showPassword),
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final v = value ?? '';
                          if (v.isEmpty) {
                            return 'Please enter password!';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.forgotPassword,
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),
                      GradientElevatedButton(
                        text: 'Login',
                        height: 54,
                        borderRadius: 18,
                        onPressed: () async {
                          final isValid =
                              _formkey.currentState?.validate() ?? false;
                          if (!isValid) return;

                          try {
                            await ref
                                .read(loginUseCaseProvider)
                                .call(
                                  email: _loginEmailController.text,
                                  password: _loginPassController.text,
                                  roleIndex: 1,
                                );

                            ref.invalidate(currentUserProvider);
                            ref.invalidate(adminIssuesControllerProvider);
                            ref.invalidate(unreadCountProvider);
                            ref.invalidate(notificationsControllerProvider);

                            final biometricOk = await _requireBiometric();
                            if (!biometricOk) return;

                            if (!context.mounted) return;
                            showMySnackBar(
                              context: context,
                              message: 'Login Successful (Admin)!',
                            );

                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.adminDashboard,
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            showMySnackBar(
                              context: context,
                              message: e.toString(),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        },
                        child: Text(
                          'Citizen / Authority Login',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
