import 'package:flutter/material.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/widgets/gradiant_elevated_button.dart';
import 'package:sajilofix/features/auth/presentation/pages/login_page.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/dropdown_field.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/labeled_field.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/password_strength.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/password_strength_meter.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/role_card.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/section_card.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/signup_step_scaffold.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/summary_row.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final PageController _pageController = PageController();

  int _stepIndex = 0; // 0..2
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;

  int _selectedRoleIndex = 0; // 0 = Citizen, 1 = Authority

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _citizenshipController = TextEditingController();

  String? _district;
  String? _municipality;
  String? _ward;
  final TextEditingController _toleController = TextEditingController();

  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _citizenshipController.dispose();
    _toleController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  double _progressValueForStep(int stepIndex) {
    return (stepIndex + 1) / 3;
  }

  void _goToStep(int stepIndex) {
    setState(() => _stepIndex = stepIndex);
    _pageController.animateToPage(
      stepIndex,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _handleBack() {
    if (_stepIndex == 0) {
      Navigator.maybePop(context);
      return;
    }
    _goToStep(_stepIndex - 1);
  }

  void _handleContinue() {
    final currentForm = switch (_stepIndex) {
      0 => _step1Key,
      1 => _step2Key,
      _ => _step3Key,
    };

    final isValid = currentForm.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_stepIndex < 2) {
      _goToStep(_stepIndex + 1);
    }
  }

  void _handleCreateAccount() {
    final isValid = _step3Key.currentState?.validate() ?? false;
    if (!isValid) return;

    if (!_acceptedTerms || !_acceptedPrivacy) {
      showMySnackBar(
        context: context,
        message: 'Please accept Terms & Conditions and Privacy Policy',
      );
      return;
    }

    showMySnackBar(context: context, message: 'Account Created Successfully');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    final strength = passwordStrength(_passController.text);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                'assets/images/sajilofix_logo.png',
                height: 90,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _handleBack,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step ${_stepIndex + 1} of 3',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: _progressValueForStep(_stepIndex),
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(primary),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Login',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SignupStepScaffold(
                    icon: Icons.person_outline,
                    title: 'General Information',
                    subtitle: "Let's start with your basic details",
                    child: Form(
                      key: _step1Key,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          LabeledField(
                            label: 'Full Name *',
                            child: TextFormField(
                              controller: _fullNameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person_outline),
                                hintText: 'Enter your full name',
                              ),
                              validator: (value) {
                                final v = value?.trim() ?? '';
                                if (v.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          LabeledField(
                            label: 'Email Address *',
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.mail_outline),
                                hintText: 'your.email@example.com',
                              ),
                              validator: (value) {
                                final v = value?.trim() ?? '';
                                if (v.isEmpty) {
                                  return 'Please enter email';
                                }
                                if (!v.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          LabeledField(
                            label: 'Phone Number *',
                            child: Row(
                              children: [
                                Container(
                                  height: 56,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: theme.dividerColor.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '+977',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: muted,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.phone_outlined),
                                      hintText: '9841234567',
                                    ),
                                    validator: (value) {
                                      final v = value?.trim() ?? '';
                                      if (v.isEmpty) {
                                        return 'Please enter phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          LabeledField(
                            label: 'Date of Birth (Optional)',
                            child: TextFormField(
                              controller: _dobController,
                              keyboardType: TextInputType.datetime,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: '01/01/2026',
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          LabeledField(
                            label: 'Citizenship Number (Optional)',
                            child: TextFormField(
                              controller: _citizenshipController,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.badge_outlined),
                                hintText: 'e.g., 123-456-789',
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'I am registering as: *',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: RoleCard(
                                  selected: _selectedRoleIndex == 0,
                                  title: 'Citizen',
                                  subtitle: 'Report issues',
                                  icon: Icons.person_outline,
                                  onTap: () =>
                                      setState(() => _selectedRoleIndex = 0),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RoleCard(
                                  selected: _selectedRoleIndex == 1,
                                  title: 'Authority',
                                  subtitle: 'Manage issues',
                                  icon: Icons.apartment_outlined,
                                  onTap: () =>
                                      setState(() => _selectedRoleIndex = 1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SignupStepScaffold(
                    icon: Icons.location_on_outlined,
                    title: 'Location Details',
                    subtitle: 'Help us show you relevant issues in your area',
                    child: Form(
                      key: _step2Key,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              showMySnackBar(
                                context: context,
                                message: 'Location access coming soon',
                              );
                            },
                            icon: const Icon(Icons.my_location_outlined),
                            label: const Text('Use My Current Location'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: theme.dividerColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  'OR ENTER MANUALLY',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: muted,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: theme.dividerColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          LabeledField(
                            label: 'District *',
                            child: DropdownField(
                              value: _district,
                              hintText: 'Select district',
                              items: const [
                                'Kathmandu',
                                'Lalitpur',
                                'Bhaktapur',
                              ],
                              onChanged: (value) =>
                                  setState(() => _district = value),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select district';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          LabeledField(
                            label: 'Municipality / Rural Municipality *',
                            child: DropdownField(
                              value: _municipality,
                              hintText: 'Select municipality',
                              items: const [
                                'Tokha',
                                'Kirtipur',
                                'Budhanilkantha',
                              ],
                              onChanged: (value) =>
                                  setState(() => _municipality = value),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select municipality';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          LabeledField(
                            label: 'Ward Number *',
                            child: DropdownField(
                              value: _ward,
                              hintText: 'Select ward',
                              items: const ['Ward 1', 'Ward 2', 'Ward 3'],
                              onChanged: (value) =>
                                  setState(() => _ward = value),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select ward';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          LabeledField(
                            label: 'Tole / Street Name (Optional)',
                            child: TextFormField(
                              controller: _toleController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.place_outlined),
                                hintText: 'e.g., Thamel, Bouddha',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SignupStepScaffold(
                    icon: Icons.shield_outlined,
                    title: 'Security & Verification',
                    subtitle: 'Set up your password and confirm your details',
                    child: Form(
                      key: _step3Key,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          LabeledField(
                            label: 'Password *',
                            child: TextFormField(
                              controller: _passController,
                              obscureText: !_showPassword,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                    () => _showPassword = !_showPassword,
                                  ),
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                hintText: 'Enter password',
                              ),
                              validator: (value) {
                                final v = value?.trim() ?? '';
                                if (v.isEmpty) {
                                  return 'Please enter password';
                                }
                                if (v.length < 8) {
                                  return 'At least 8 characters required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          PasswordStrengthMeter(strength: strength),
                          const SizedBox(height: 10),
                          Text(
                            '• At least 8 characters\n• Upper and lowercase letters\n• At least one number',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          LabeledField(
                            label: 'Confirm Password *',
                            child: TextFormField(
                              controller: _confirmPassController,
                              obscureText: !_showConfirmPassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                    () => _showConfirmPassword =
                                        !_showConfirmPassword,
                                  ),
                                  icon: Icon(
                                    _showConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                hintText: 'Re-enter password',
                              ),
                              validator: (value) {
                                final v = value ?? '';
                                if (v.isEmpty) {
                                  return 'Please confirm password';
                                }
                                if (v != _passController.text) {
                                  return "Passwords don't match";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          SectionCard(
                            title: 'Account Summary',
                            leading: Icons.description_outlined,
                            child: Column(
                              children: [
                                SummaryRow(
                                  label: 'Full Name:',
                                  value: _fullNameController.text.isEmpty
                                      ? '-'
                                      : _fullNameController.text,
                                ),
                                SummaryRow(
                                  label: 'Email:',
                                  value: _emailController.text.isEmpty
                                      ? '-'
                                      : _emailController.text,
                                ),
                                SummaryRow(
                                  label: 'Phone:',
                                  value: _phoneController.text.isEmpty
                                      ? '-'
                                      : '+977 ${_phoneController.text}',
                                ),
                                SummaryRow(
                                  label: 'Role:',
                                  value: _selectedRoleIndex == 0
                                      ? 'Citizen'
                                      : 'Authority',
                                ),
                                SummaryRow(
                                  label: 'Location:',
                                  value:
                                      [
                                        if (_ward != null) _ward!,
                                        if (_municipality != null)
                                          _municipality!,
                                        if (_district != null) _district!,
                                      ].isEmpty
                                      ? '-'
                                      : [
                                          if (_ward != null) _ward!,
                                          if (_municipality != null)
                                            _municipality!,
                                          if (_district != null) _district!,
                                        ].join(', '),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          SectionCard(
                            title: 'Legal Agreements',
                            leading: Icons.shield_outlined,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CheckboxListTile(
                                  value: _acceptedTerms,
                                  onChanged: (v) => setState(
                                    () => _acceptedTerms = v ?? false,
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: Text(
                                    'I have read and agree to the Terms & Conditions',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                CheckboxListTile(
                                  value: _acceptedPrivacy,
                                  onChanged: (v) => setState(
                                    () => _acceptedPrivacy = v ?? false,
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: Text(
                                    'I acknowledge the Privacy Policy and consent to data processing',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: _stepIndex < 2
            ? SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              )
            : GradientElevatedButton(
                text: 'Create Account',
                height: 54,
                borderRadius: 999,
                onPressed: _handleCreateAccount,
              ),
      ),
    );
  }
}
