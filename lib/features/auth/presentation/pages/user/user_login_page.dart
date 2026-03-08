import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/core/widgets/gradiant_elevated_button.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/constants/hero_tags.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/providers/citizen_home_providers.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';

class UserLoginScreen extends ConsumerStatefulWidget {
  const UserLoginScreen({super.key});

  @override
  ConsumerState<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends ConsumerState<UserLoginScreen> {
  bool showPassword = false;

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPassController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  bool _isAdminEmail(String email) {
    return email.trim().toLowerCase() == 'admin@sajilofix.com';
  }

  bool _isAuthorityEmail(String email) {
    return email.trim().toLowerCase().endsWith('@sajilofix.gov.np');
  }

  int _roleIndexForEmail(String email) {
    if (_isAuthorityEmail(email)) return 2;
    return 0;
  }

  String? _validateUserEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter email';
    if (!v.contains('@')) return 'Please enter valid email';

    if (_isAdminEmail(v)) {
      return 'Admin email must login from Admin Login';
    }

    return null;
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

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
                        'Citizen / Authority Login',
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
                          hintText: 'your.email@example.com',
                        ),
                        validator: _validateUserEmail,
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

                          final email = _loginEmailController.text;
                          final roleIndex = _roleIndexForEmail(email);

                          try {
                            await ref
                                .read(loginUseCaseProvider)
                                .call(
                                  email: email,
                                  password: _loginPassController.text,
                                  roleIndex: roleIndex,
                                );

                            ref.invalidate(currentUserProvider);
                            ref.invalidate(myReportsProvider);
                            ref.invalidate(citizenHomeStatsProvider);

                            if (!context.mounted) return;
                            showMySnackBar(
                              context: context,
                              message: roleIndex == 2
                                  ? 'Login Successful (Authority)!'
                                  : 'Login Successful (Citizen)!',
                            );

                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.dashboard,
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
                          Navigator.pushNamed(context, AppRoutes.adminLogin);
                        },
                        child: Text(
                          'Admin Login',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: theme.dividerColor.withValues(alpha: 0.5),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'OR',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: muted,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: theme.dividerColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _SocialButton(
                        label: 'Continue with Google',
                        leading: const Icon(Icons.g_mobiledata, size: 28),
                        onPressed: () {
                          showMySnackBar(
                            context: context,
                            message: 'Google sign-in coming soon',
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _SocialButton(
                        label: 'Continue with Nagarik App',
                        leading: const Icon(Icons.account_balance, size: 20),
                        onPressed: () {
                          showMySnackBar(
                            context: context,
                            message: 'Nagarik sign-in coming soon',
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _SocialButton(
                        label: 'Use Face ID / Touch ID',
                        leading: const Icon(Icons.fingerprint, size: 20),
                        onPressed: () {
                          showMySnackBar(
                            context: context,
                            message: 'Biometric sign-in coming soon',
                          );
                        },
                      ),

                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: muted,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.signup,
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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

class _SocialButton extends StatelessWidget {
  final Widget leading;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.leading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.35)),
          backgroundColor: theme.colorScheme.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 10),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
