import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/core/widgets/gradiant_elevated_button.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/constants/hero_tags.dart';
import 'package:sajilofix/core/services/biometrics/biometric_service.dart';
import 'package:sajilofix/core/services/storage/biometric_credentials_service.dart';
import 'package:sajilofix/core/services/storage/app_preferences.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/providers/citizen_home_providers.dart';
import 'package:sajilofix/features/dashboard/authority/presentation/providers/authority_issues_providers.dart';
import 'package:sajilofix/features/notifications/presentation/providers/notification_providers.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';

class UserLoginScreen extends ConsumerStatefulWidget {
  const UserLoginScreen({super.key});

  @override
  ConsumerState<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends ConsumerState<UserLoginScreen> {
  bool showPassword = false;
  bool _isBiometricEnabledForRole = false;

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
  void initState() {
    super.initState();
    _loginEmailController.addListener(_onEmailChanged);
    _refreshBiometricCardState();
  }

  void _onEmailChanged() {
    _refreshBiometricCardState();
  }

  Future<void> _refreshBiometricCardState() async {
    final typedEmail = _loginEmailController.text.trim();
    var roleIndex = _roleIndexForEmail(typedEmail);

    if (typedEmail.isEmpty) {
      final saved = await BiometricCredentialsService.read();
      if (saved != null) {
        roleIndex = saved.roleIndex;
      }
    }

    final enabled = await AppPreferences.isBiometricEnabled(
      roleIndex: roleIndex,
    );

    if (!mounted || enabled == _isBiometricEnabledForRole) return;
    setState(() => _isBiometricEnabledForRole = enabled);
  }

  @override
  void dispose() {
    _loginEmailController.removeListener(_onEmailChanged);
    _loginEmailController.dispose();
    _loginPassController.dispose();
    super.dispose();
  }

  Future<bool> _verifyBiometricForCard(int roleIndex) async {
    final enabled = await AppPreferences.isBiometricEnabled(
      roleIndex: roleIndex,
    );
    if (!enabled) {
      showMySnackBar(
        context: context,
        message: 'Turn on biometric login in Security settings first.',
        isError: true,
      );
      return false;
    }

    final service = BiometricService();
    final available = await service.isAvailable();
    if (!available) {
      showMySnackBar(
        context: context,
        message: 'Biometric is not available on this device.',
        isError: true,
      );
      return false;
    }

    final ok = await service.authenticate(
      reason: 'Use Face ID / Touch ID to sign in',
    );
    if (!ok) {
      showMySnackBar(
        context: context,
        message: 'Biometric authentication failed.',
        isError: true,
      );
      return false;
    }

    return true;
  }

  Future<BiometricCredentials?> _resolveBiometricCredentials() async {
    final typedEmail = _loginEmailController.text.trim();
    final typedPassword = _loginPassController.text;

    if (typedEmail.isNotEmpty && typedPassword.isNotEmpty) {
      return BiometricCredentials(
        email: typedEmail,
        password: typedPassword,
        roleIndex: _roleIndexForEmail(typedEmail),
      );
    }

    final saved = await BiometricCredentialsService.read();
    if (saved == null) {
      showMySnackBar(
        context: context,
        message:
            'No saved biometric credentials found. Login once with email and password first.',
        isError: true,
      );
      return null;
    }

    return saved;
  }

  Future<void> _completeLoginSuccess(int roleIndex) async {
    ref.invalidate(currentUserProvider);
    ref.invalidate(myReportsProvider);
    ref.invalidate(citizenHomeStatsProvider);
    ref.invalidate(unreadCountProvider);
    ref.invalidate(notificationsControllerProvider);
    if (roleIndex == 2) {
      ref.invalidate(authorityIssuesControllerProvider);
    }

    if (!context.mounted) return;
    showMySnackBar(
      context: context,
      message: roleIndex == 2
          ? 'Login Successful (Authority)!'
          : 'Login Successful (Citizen)!',
    );

    final target = roleIndex == 2
        ? AppRoutes.authorityDashboard
        : AppRoutes.dashboard;
    Navigator.pushReplacementNamed(context, target);
  }

  Future<void> _performLogin({required bool fromBiometricCard}) async {
    if (fromBiometricCard) {
      final creds = await _resolveBiometricCredentials();
      if (creds == null) return;

      final roleIndex = creds.roleIndex;
      final biometricOk = await _verifyBiometricForCard(roleIndex);
      if (!biometricOk) return;

      try {
        await ref
            .read(loginUseCaseProvider)
            .call(
              email: creds.email,
              password: creds.password,
              roleIndex: roleIndex,
            );

        _loginEmailController.text = creds.email;
        await _completeLoginSuccess(roleIndex);
      } catch (e) {
        if (!context.mounted) return;
        showMySnackBar(context: context, message: e.toString());
      }
      return;
    }

    final isValid = _formkey.currentState?.validate() ?? false;
    if (!isValid) return;

    final email = _loginEmailController.text;
    final password = _loginPassController.text;
    final roleIndex = _roleIndexForEmail(email);

    try {
      await ref
          .read(loginUseCaseProvider)
          .call(email: email, password: password, roleIndex: roleIndex);

      final enabled = await AppPreferences.isBiometricEnabled(
        roleIndex: roleIndex,
      );
      if (enabled) {
        await BiometricCredentialsService.save(
          email: email,
          password: password,
          roleIndex: roleIndex,
        );
      }

      await _completeLoginSuccess(roleIndex);
    } catch (e) {
      if (!context.mounted) return;
      showMySnackBar(context: context, message: e.toString());
    }
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
                        onPressed: () =>
                            _performLogin(fromBiometricCard: false),
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
                        enabled: _isBiometricEnabledForRole,
                        onPressed: () => _performLogin(fromBiometricCard: true),
                      ),
                      if (!_isBiometricEnabledForRole)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Enable biometric login in Security settings to use this option.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                            ),
                          ),
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
  final bool enabled;

  const _SocialButton({
    required this.leading,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
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
