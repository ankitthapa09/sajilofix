import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/constants/hero_tags.dart';
import 'package:sajilofix/core/widgets/gradiant_elevated_button.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/dropdown_field.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/labeled_field.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/password_strength.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/password_strength_meter.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/role_card.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/section_card.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/signup_step_scaffold.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/summary_row.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final PageController _pageController = PageController();
  late final List<ScrollController> _stepScrollControllers;

  int _stepIndex = 0; // 0..2
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;

  int _selectedRoleIndex = 0; // 0 = Citizen, 1 = Authority

  int _displayRoleIndex = 0; // UI-only role selection

  bool _authorityPulseActive = false;
  Timer? _authorityPulseTimer;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _phoneCountryCode; // e.g. +977
  String? _phoneNationalNumber; // e.g. 9841234567
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _citizenshipController = TextEditingController();

  String? _district;
  String? _municipality;
  String? _ward;
  final TextEditingController _toleController = TextEditingController();

  static const List<String> _districts = ['Kathmandu', 'Lalitpur', 'Bhaktapur'];

  static const Map<String, List<String>> _districtToMunicipalities = {
    'Kathmandu': [
      'Kathmandu Metropolitan City',
      'Tokha Municipality',
      'Tarkeswor Municipality',
      'Budhanilkantha Municipality',
    ],
    'Lalitpur': [
      'Lalitpur Metropolitan City',
      'Mahalaxmi Municipality',
      'Godawari Municipality',
    ],
    'Bhaktapur': [
      'Bhaktapur Municipality',
      'Madhyapur Thimi Municipality',
      'Suryabinayak Municipality',
    ],
  };

  static const Map<String, int> _municipalityToWardCount = {
    'Kathmandu Metropolitan City': 9,
    'Tokha Municipality': 11,
    'Tarkeswor Municipality': 10,
    'Budhanilkantha Municipality': 13,
    'Lalitpur Metropolitan City': 29,
    'Mahalaxmi Municipality': 10,
    'Godawari Municipality': 14,
    'Bhaktapur Municipality': 10,
    'Madhyapur Thimi Municipality': 9,
    'Suryabinayak Municipality': 10,
  };

  List<String> _municipalitiesForDistrict(String? district) {
    if (district == null) return const [];
    return _districtToMunicipalities[district] ?? const [];
  }

  List<String> _wardsForMunicipality(String? municipality) {
    if (municipality == null) return const [];
    final count = _municipalityToWardCount[municipality];
    if (count == null || count <= 0) return const [];
    return List<String>.generate(count, (i) => 'Ward ${i + 1}');
  }

  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  DateTime? _parseDob(String text) {
    final v = text.trim();
    if (v.isEmpty) return null;

    // Expected format: DD/MM/YYYY
    final parts = v.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (year < 1900 || month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }
    try {
      final d = DateTime(year, month, day);
      // Validate that DateTime didn't auto-roll (e.g. 31/02).
      if (d.year != year || d.month != month || d.day != day) return null;
      return d;
    } catch (_) {
      return null;
    }
  }

  String _formatDob(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();

    final now = DateTime.now();
    final lastDate = DateTime(now.year, now.month, now.day);
    final firstDate = DateTime(1900, 1, 1);

    var initial = _parseDob(_dobController.text) ?? lastDate;
    if (initial.isAfter(lastDate)) initial = lastDate;
    if (initial.isBefore(firstDate)) initial = firstDate;

    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Date of Birth',
    );

    if (!mounted || selected == null) return;
    setState(() {
      _dobController.text = _formatDob(selected);
    });
  }

  String _formatPhoneForSummary(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return v;

    // Prefer the parsed pieces from IntlPhoneField to avoid guessing lengths.
    final code = _phoneCountryCode?.trim();
    final national = _phoneNationalNumber?.trim();
    if (code != null &&
        code.isNotEmpty &&
        national != null &&
        national.isNotEmpty) {
      return '$code $national';
    }

    // Fallback: if already spaced, keep it.
    if (v.contains(' ')) return v;
    return v;
  }

  @override
  void initState() {
    super.initState();
    _stepScrollControllers = List.generate(3, (_) => ScrollController());
    for (final c in _stepScrollControllers) {
      c.addListener(() {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _authorityPulseTimer?.cancel();
    for (final c in _stepScrollControllers) {
      c.dispose();
    }
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final c = _stepScrollControllers[stepIndex];
      if (c.hasClients) {
        c.jumpTo(0);
      }
    });
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

    () async {
      try {
        await ref
            .read(signupUseCaseProvider)
            .call(
              fullName: _fullNameController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              roleIndex: _selectedRoleIndex,
              password: _passController.text,
              dob: _dobController.text,
              citizenshipNumber: _citizenshipController.text,
              district: _district,
              municipality: _municipality,
              ward: _ward,
              tole: _toleController.text,
            );

        if (!mounted) return;
        showMySnackBar(
          context: context,
          message: 'Account created successfully. Please log in.',
        );

        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } catch (e) {
        if (!mounted) return;
        showMySnackBar(context: context, message: e.toString());
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    final strength = passwordStrength(_passController.text);

    final activeScrollController = _stepScrollControllers[_stepIndex];
    const double maxHeaderScroll = 80.0;
    final double headerOffset =
        (activeScrollController.hasClients
                ? activeScrollController.offset
                : 0.0)
            .clamp(0.0, maxHeaderScroll)
            .toDouble();
    final double t = (headerOffset / maxHeaderScroll)
        .clamp(0.0, 1.0)
        .toDouble();
    final double logoOpacity = (1 - t).clamp(0.0, 1.0).toDouble();
    final double logoHeightFactor = logoOpacity;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_stepIndex == 0)
                    const SizedBox(width: 48, height: 48)
                  else
                    IconButton(
                      onPressed: _handleBack,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Step ${_stepIndex + 1} of 3',
                                      textAlign: TextAlign.left,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(color: muted),
                                    ),
                                    const SizedBox(height: 8),
                                    _GradientProgressBar(
                                      value: _progressValueForStep(_stepIndex),
                                      height: 6,
                                      backgroundColor: theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF3533cd),
                                          Color(0xFF041027),
                                          Color(0xFF3533cd),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Bigger + aligned exactly with progress start
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.login,
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        foregroundColor: primary,
                                        textStyle: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      child: const Text('Login'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            ClipRect(
                              child: Align(
                                alignment: Alignment.centerRight,
                                heightFactor: logoHeightFactor,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 120),
                                  opacity: logoOpacity,
                                  child: Hero(
                                    tag: HeroTags.appLogo,
                                    child: Image.asset(
                                      'assets/images/sajilofix_logo.png',
                                      height: 90,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SignupStepScaffold(
                    icon: Icons.person_outline,
                    title: 'General Information',
                    subtitle: "Let's start with your basic details",
                    scrollController: _stepScrollControllers[0],
                    child: Form(
                      key: _step1Key,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 4),
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
                            child: IntlPhoneField(
                              initialCountryCode: 'NP',
                              showCountryFlag: true,
                              showDropdownIcon: true,
                              dropdownIconPosition: IconPosition.trailing,
                              disableLengthCheck: true,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.phone_outlined),
                                hintText: '9841234567',
                              ),
                              onChanged: (phone) {
                                // Keep the controller holding the full number (e.g. +9779841234567)
                                _phoneController.text = phone.completeNumber;

                                final cc = phone.countryCode.trim();
                                _phoneCountryCode = cc.isEmpty
                                    ? null
                                    : (cc.startsWith('+') ? cc : '+$cc');

                                final national = phone.number.trim();
                                _phoneNationalNumber = national.isEmpty
                                    ? null
                                    : national;
                              },
                              validator: (phone) {
                                final complete = phone?.completeNumber.trim();
                                if (complete == null || complete.isEmpty) {
                                  return 'Please enter phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          LabeledField(
                            label: 'Date of Birth (Optional)',
                            child: TextFormField(
                              controller: _dobController,
                              readOnly: true,
                              showCursor: false,
                              textInputAction: TextInputAction.next,
                              onTap: _pickDob,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.calendar_month_outlined,
                                ),
                                hintText: 'DD/MM/YYYY',
                                suffixIcon: IconButton(
                                  onPressed: _pickDob,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                ),
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
                                  selected: _displayRoleIndex == 0,
                                  title: 'Citizen',
                                  subtitle: 'Report issues',
                                  icon: Icons.person_outline,
                                  onTap: () {
                                    _authorityPulseTimer?.cancel();
                                    setState(() {
                                      _authorityPulseActive = false;
                                      _displayRoleIndex = 0;
                                      _selectedRoleIndex = 0;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RoleCard(
                                  selected: _displayRoleIndex == 1,
                                  title: 'Authority',
                                  subtitle: 'Manage issues',
                                  icon: Icons.apartment_outlined,
                                  borderColor: _authorityPulseActive
                                      ? theme.colorScheme.error
                                      : null,
                                  borderWidth: _authorityPulseActive ? 2 : null,
                                  onTap: () {
                                    showMySnackBar(
                                      context: context,
                                      message:
                                          'Authority Account Cannot be self created',
                                    );

                                    _authorityPulseTimer?.cancel();
                                    setState(() {
                                      _authorityPulseActive = true;
                                      _displayRoleIndex = 1;
                                      _selectedRoleIndex = 0;
                                    });

                                    _authorityPulseTimer = Timer(
                                      const Duration(milliseconds: 2700),
                                      () {
                                        if (!mounted) return;
                                        setState(() {
                                          _authorityPulseActive = false;
                                          _displayRoleIndex = 0;
                                        });
                                      },
                                    );
                                  },
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
                    scrollController: _stepScrollControllers[1],
                    child: Form(
                      key: _step2Key,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 4),
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
                              items: _districts,
                              onChanged: (value) {
                                setState(() {
                                  _district = value;
                                  _municipality = null;
                                  _ward = null;
                                });
                              },
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
                              key: ValueKey(
                                'municipality_${_district ?? 'none'}',
                              ),
                              value: _municipality,
                              hintText: _district == null
                                  ? 'Select district first'
                                  : 'Select municipality',
                              enabled: _district != null,
                              items: _municipalitiesForDistrict(_district),
                              onChanged: (value) {
                                setState(() {
                                  _municipality = value;
                                  _ward = null;
                                });
                              },
                              validator: (value) {
                                if (_district == null) return null;
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
                              key: ValueKey(
                                'ward_${_district ?? 'none'}_${_municipality ?? 'none'}',
                              ),
                              value: _ward,
                              hintText: _municipality == null
                                  ? 'Select municipality first'
                                  : 'Select ward',
                              enabled: _municipality != null,
                              items: _wardsForMunicipality(_municipality),
                              onChanged: (value) =>
                                  setState(() => _ward = value),
                              validator: (value) {
                                if (_municipality == null) return null;
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
                    scrollController: _stepScrollControllers[2],
                    child: Form(
                      key: _step3Key,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 4),
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
                              onChanged: (_) => setState(() {}),
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
                          const SizedBox(height: 8),
                          Builder(
                            builder: (context) {
                              final pass = _passController.text;
                              final confirm = _confirmPassController.text;

                              if (confirm.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              final matches =
                                  pass.isNotEmpty && confirm == pass;
                              final color = matches
                                  ? const Color(0xFF22C55E)
                                  : theme.colorScheme.error;
                              final icon = matches
                                  ? Icons.check_circle_rounded
                                  : Icons.error_rounded;
                              final text = matches
                                  ? 'Passwords match'
                                  : "Passwords don't match";

                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 160),
                                child: Row(
                                  key: ValueKey(matches),
                                  children: [
                                    Icon(icon, size: 18, color: color),
                                    const SizedBox(width: 8),
                                    Text(
                                      text,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: color,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              final dob = _dobController.text.trim();
                              final citizenship = _citizenshipController.text
                                  .trim();
                              final tole = _toleController.text.trim();

                              final line1Parts = <String>[
                                if (_municipality != null) _municipality!,
                                if (_ward != null) _ward!,
                                if (tole.isNotEmpty) tole,
                              ];
                              final district = _district?.trim();

                              final String locationValue;
                              if (line1Parts.isEmpty &&
                                  (district == null || district.isEmpty)) {
                                locationValue = '-';
                              } else if (district == null || district.isEmpty) {
                                locationValue = line1Parts.join(' • ');
                              } else if (line1Parts.isEmpty) {
                                locationValue = district;
                              } else {
                                locationValue =
                                    '${line1Parts.join(' • ')}\n$district';
                              }

                              final summaryData =
                                  <
                                    ({
                                      String label,
                                      IconData icon,
                                      String value,
                                      int? maxLines,
                                    })
                                  >[
                                    (
                                      label: 'Full Name:',
                                      icon: Icons.person_outline,
                                      value: _fullNameController.text.isEmpty
                                          ? '-'
                                          : _fullNameController.text,
                                      maxLines: null,
                                    ),
                                    (
                                      label: 'Email:',
                                      icon: Icons.mail_outline,
                                      value: _emailController.text.isEmpty
                                          ? '-'
                                          : _emailController.text,
                                      maxLines: 1,
                                    ),
                                    (
                                      label: 'Phone:',
                                      icon: Icons.phone_outlined,
                                      value: _phoneController.text.isEmpty
                                          ? '-'
                                          : _formatPhoneForSummary(
                                              _phoneController.text,
                                            ),
                                      maxLines: 1,
                                    ),
                                    (
                                      label: 'Role:',
                                      icon: Icons.badge_outlined,
                                      value: _selectedRoleIndex == 0
                                          ? 'Citizen'
                                          : 'Authority',
                                      maxLines: 1,
                                    ),
                                    if (dob.isNotEmpty)
                                      (
                                        label: 'Date of Birth:',
                                        icon: Icons.cake_outlined,
                                        value: dob,
                                        maxLines: 1,
                                      ),
                                    if (citizenship.isNotEmpty)
                                      (
                                        label: 'Citizenship No.:',
                                        icon: Icons.badge_outlined,
                                        value: citizenship,
                                        maxLines: 1,
                                      ),
                                    (
                                      label: 'Location:',
                                      icon: Icons.location_on_outlined,
                                      value: locationValue,
                                      maxLines: 3,
                                    ),
                                  ];

                              return SectionCard(
                                title: 'Account Summary',
                                leading: Icons.description_outlined,
                                child: Column(
                                  children: List.generate(summaryData.length, (
                                    i,
                                  ) {
                                    final row = summaryData[i];
                                    return SummaryRow(
                                      label: row.label,
                                      icon: row.icon,
                                      value: row.value,
                                      valueMaxLines: row.maxLines,
                                      showDivider: i != summaryData.length - 1,
                                    );
                                  }),
                                ),
                              );
                            },
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

class _GradientProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color backgroundColor;
  final LinearGradient gradient;

  const _GradientProgressBar({
    required this.value,
    required this.height,
    required this.backgroundColor,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(decoration: BoxDecoration(color: backgroundColor)),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: clampedValue),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: animatedValue,
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: gradient),
                      child: const SizedBox.expand(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
