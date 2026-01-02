import 'package:flutter/material.dart';
import 'package:sajilofix/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sajilofix/features/auth/presentation/pages/forget_password/forget_password_screen.dart';
import 'package:sajilofix/features/auth/presentation/pages/signup_page.dart';
import 'package:sajilofix/core/widgets/gradiant_elevated_button.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showPassword = false;

  int _selectedRoleIndex = 0; // 0 = Citizen, 1 = Admin

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPassController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

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
                Image.asset('assets/images/sajilofix_logo.png', height: 90),
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
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Citizen / Admin selector
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _RoleChip(
                                text: 'Citizen',
                                selected: _selectedRoleIndex == 0,
                                onTap: () =>
                                    setState(() => _selectedRoleIndex = 0),
                              ),
                            ),
                            Expanded(
                              child: _RoleChip(
                                text: 'Admin',
                                selected: _selectedRoleIndex == 1,
                                onTap: () =>
                                    setState(() => _selectedRoleIndex = 1),
                              ),
                            ),
                          ],
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
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!v.contains('@')) {
                            return 'Please enter valid email';
                          }
                          return null;
                        },
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgetpasswordScreen(),
                              ),
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
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            showMySnackBar(
                              context: context,
                              message: _selectedRoleIndex == 0
                                  ? 'Login Successful (Citizen)!'
                                  : 'Login Successful (Admin)!',
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CitizenDashboard(),
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 16),
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
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
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

class _RoleChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: selected
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
