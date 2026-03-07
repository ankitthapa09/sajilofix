import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/features/dashboard/admin/domain/entities/admin_user_row.dart';
import 'package:sajilofix/features/dashboard/admin/presentation/providers/admin_users_providers.dart';

class AdminUserFormPage extends ConsumerStatefulWidget {
  final String role;
  final AdminUserRow? user;

  const AdminUserFormPage({super.key, required this.role, this.user});

  @override
  ConsumerState<AdminUserFormPage> createState() => _AdminUserFormPageState();
}

class _AdminUserFormPageState extends ConsumerState<AdminUserFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  bool _showPassword = false;
  bool _loadingDetails = false;

  AnimationController? _animController;
  Animation<double> _fadeAnim = const AlwaysStoppedAnimation(1.0);

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _wardController;
  late final TextEditingController _municipalityController;
  late final TextEditingController _departmentController;
  late final TextEditingController _districtController;
  late final TextEditingController _toleController;
  late final TextEditingController _dobController;
  late final TextEditingController _citizenshipController;
  late final TextEditingController _passwordController;

  String _status = 'active';
  Map<String, String> _initialValues = const {};

  bool get _isEdit => widget.user != null;
  bool get _isAuthority => widget.role == 'authority';

  // ── colours ──────────────────────────────────────────────
  static const _blue = Color(0xFF2563EB);
  static const _indigo = Color(0xFF4F46E5);
  static const _green = Color(0xFF059669);
  static const _amber = Color(0xFFD97706);

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeOut,
    );
    _animController!.forward();

    final user = widget.user;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _wardController = TextEditingController(text: user?.wardNumber ?? '');
    _municipalityController = TextEditingController(
      text: user?.municipality ?? '',
    );
    _departmentController = TextEditingController(text: user?.department ?? '');
    _districtController = TextEditingController(text: user?.district ?? '');
    _toleController = TextEditingController(text: user?.tole ?? '');
    _dobController = TextEditingController(text: user?.dob ?? '');
    _citizenshipController = TextEditingController(
      text: user?.citizenshipNumber ?? '',
    );
    _passwordController = TextEditingController();
    _status = user?.status ?? 'active';
    _captureInitialValues();

    if (_isEdit && user != null) {
      Future.microtask(() => _loadUserDetails(user));
    }
  }

  @override
  void dispose() {
    _animController?.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _wardController.dispose();
    _municipalityController.dispose();
    _departmentController.dispose();
    _districtController.dispose();
    _toleController.dispose();
    _dobController.dispose();
    _citizenshipController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── submit ───────────────────────────────────────────────
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final ctrl = ref.read(adminUsersControllerProvider.notifier);
      if (_isEdit) {
        final fullName = _nullIfEmpty(_fullNameController.text);
        final email = _nullIfEmpty(_emailController.text);
        final password = _nullIfEmpty(_passwordController.text);
        final phone = _nullIfEmpty(_phoneController.text);
        final ward = _nullIfEmpty(_wardController.text);
        final municipality = _nullIfEmpty(_municipalityController.text);
        final department = _nullIfEmpty(_departmentController.text);
        final district = _nullIfEmpty(_districtController.text);
        final tole = _nullIfEmpty(_toleController.text);
        final dob = _nullIfEmpty(_dobController.text);
        final citizenship = _nullIfEmpty(_citizenshipController.text);

        if (_isAuthority) {
          await ctrl.updateAuthority(
            id: widget.user!.id,
            fullName: fullName,
            email: email,
            password: password,
            phone: phone,
            wardNumber: ward,
            municipality: municipality,
            department: department,
            status: _status,
          );
        } else {
          await ctrl.updateCitizen(
            id: widget.user!.id,
            fullName: fullName,
            email: email,
            password: password,
            phone: phone,
            wardNumber: ward,
            municipality: municipality,
            status: _status,
            district: district,
            tole: tole,
            dob: dob,
            citizenshipNumber: citizenship,
          );
        }
      } else {
        if (_isAuthority) {
          await ctrl.createAuthority(
            fullName: _fullNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phone: _phoneController.text,
            wardNumber: _wardController.text,
            municipality: _municipalityController.text,
            department: _departmentController.text,
            status: _status,
          );
        } else {
          await ctrl.createCitizen(
            fullName: _fullNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phone: _phoneController.text,
            wardNumber: _wardController.text,
            municipality: _municipalityController.text,
            status: _status,
            district: _districtController.text,
            tole: _toleController.text,
            dob: _dobController.text,
            citizenshipNumber: _citizenshipController.text,
          );
        }
      }
      if (!mounted) return;
      _captureInitialValues();
      Navigator.pop(context, true);
      showMySnackBar(
        context: context,
        message: _isEdit
            ? 'User updated successfully.'
            : 'User created successfully.',
        icon: Icons.check_circle_outline,
      );
    } catch (e) {
      if (!mounted) return;
      showMySnackBar(
        context: context,
        message: e.toString(),
        isError: true,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0D14)
          : const Color(0xFFF0F2F8),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ───────────────────────────────────
              SliverToBoxAdapter(
                child: _AdminHeader(
                  isEdit: _isEdit,
                  isAuthority: _isAuthority,
                  loading: _loadingDetails,
                  isDark: isDark,
                  onBack: () => Navigator.pop(context),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Basic Details ─────────────────────────────
              _sectionSliver(
                context: context,
                isDark: isDark,
                icon: Icons.person_outline_rounded,
                iconColor: _blue,
                title: 'Basic Details',
                child: Column(
                  children: [
                    _AdminField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      icon: Icons.badge_outlined,
                      accentColor: _blue,
                      validator: _required,
                    ),
                    _AdminField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.alternate_email_rounded,
                      accentColor: _blue,
                      keyboardType: TextInputType.emailAddress,
                      validator: _required,
                    ),
                    _AdminField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      accentColor: _blue,
                      keyboardType: TextInputType.phone,
                      validator: _required,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _AdminField(
                            controller: _wardController,
                            label: 'Ward No.',
                            icon: Icons.location_city_outlined,
                            accentColor: _indigo,
                            keyboardType: TextInputType.number,
                            validator: _required,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AdminField(
                            controller: _municipalityController,
                            label: 'Municipality',
                            icon: Icons.apartment_outlined,
                            accentColor: _indigo,
                            validator: _required,
                          ),
                        ),
                      ],
                    ),
                    if (_isAuthority)
                      _AdminField(
                        controller: _departmentController,
                        label: 'Department',
                        icon: Icons.business_center_outlined,
                        accentColor: _indigo,
                        validator: _required,
                      ),
                  ],
                ),
              ),

              // ── Citizen-only fields ───────────────────────
              if (!_isAuthority) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                _sectionSliver(
                  context: context,
                  isDark: isDark,
                  icon: Icons.assignment_ind_outlined,
                  iconColor: const Color(0xFF7C3AED),
                  title: 'Identity & Address',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _AdminField(
                              controller: _districtController,
                              label: 'District',
                              icon: Icons.map_outlined,
                              accentColor: const Color(0xFF7C3AED),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AdminField(
                              controller: _toleController,
                              label: 'Tole / Street',
                              icon: Icons.signpost_outlined,
                              accentColor: const Color(0xFF7C3AED),
                            ),
                          ),
                        ],
                      ),
                      _AdminField(
                        controller: _dobController,
                        label: 'Date of Birth (YYYY-MM-DD)',
                        icon: Icons.cake_outlined,
                        accentColor: const Color(0xFF7C3AED),
                        keyboardType: TextInputType.datetime,
                      ),
                      _AdminField(
                        controller: _citizenshipController,
                        label: 'Citizenship Number',
                        icon: Icons.credit_card_outlined,
                        accentColor: const Color(0xFF7C3AED),
                      ),
                    ],
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Security ──────────────────────────────────
              _sectionSliver(
                context: context,
                isDark: isDark,
                icon: Icons.lock_outline_rounded,
                iconColor: _amber,
                title: 'Security',
                child: _AdminField(
                  controller: _passwordController,
                  label: _isEdit
                      ? 'New Password (leave blank to keep)'
                      : 'Password',
                  icon: Icons.key_outlined,
                  accentColor: _amber,
                  obscureText: !_showPassword,
                  validator: _isEdit ? null : _required,
                  suffix: GestureDetector(
                    onTap: () => setState(() => _showPassword = !_showPassword),
                    child: Icon(
                      _showPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: _amber.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Status ────────────────────────────────────
              _sectionSliver(
                context: context,
                isDark: isDark,
                icon: Icons.toggle_on_outlined,
                iconColor: _green,
                title: 'Account Status',
                child: _StatusSelector(
                  value: _status,
                  isDark: isDark,
                  onChanged: (v) => setState(() => _status = v),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ── Submit ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: _SubmitButton(
                    isEdit: _isEdit,
                    submitting: _submitting,
                    enabled: !_submitting && (_isEdit ? _hasChanges : true),
                    onTap: _submit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────
  SliverToBoxAdapter _sectionSliver({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _SectionCard(
          icon: icon,
          iconColor: iconColor,
          title: title,
          isDark: isDark,
          child: child,
        ),
      ),
    );
  }

  String? _required(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? 'This field is required' : null;
  }

  String? _nullIfEmpty(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? null : v;
  }

  bool get _hasChanges {
    if (!_isEdit) return true;
    return _currentValues().toString() != _initialValues.toString() ||
        _passwordController.text.trim().isNotEmpty;
  }

  Map<String, String> _currentValues() => {
    'fullName': _fullNameController.text.trim(),
    'email': _emailController.text.trim(),
    'phone': _phoneController.text.trim(),
    'wardNumber': _wardController.text.trim(),
    'municipality': _municipalityController.text.trim(),
    'department': _departmentController.text.trim(),
    'district': _districtController.text.trim(),
    'tole': _toleController.text.trim(),
    'dob': _dobController.text.trim(),
    'citizenshipNumber': _citizenshipController.text.trim(),
    'status': _status,
  };

  void _captureInitialValues() => _initialValues = _currentValues();

  Future<void> _loadUserDetails(AdminUserRow user) async {
    setState(() => _loadingDetails = true);
    try {
      final detail = await ref
          .read(adminUsersControllerProvider.notifier)
          .fetchUserDetail(id: user.id, role: user.role);
      if (detail == null || !mounted) return;
      _fullNameController.text = detail.fullName;
      _emailController.text = detail.email;
      _phoneController.text = detail.phone ?? '';
      _wardController.text = detail.wardNumber ?? '';
      _municipalityController.text = detail.municipality ?? '';
      _departmentController.text = detail.department ?? '';
      _districtController.text = detail.district ?? '';
      _toleController.text = detail.tole ?? '';
      _dobController.text = detail.dob ?? '';
      _citizenshipController.text = detail.citizenshipNumber ?? '';
      _status = detail.status;
      _captureInitialValues();
    } catch (e) {
      if (!mounted) return;
      showMySnackBar(
        context: context,
        message: e.toString(),
        isError: true,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _loadingDetails = false);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Admin Header
// ─────────────────────────────────────────────────────────────
class _AdminHeader extends StatelessWidget {
  final bool isEdit;
  final bool isAuthority;
  final bool loading;
  final bool isDark;
  final VoidCallback onBack;

  const _AdminHeader({
    required this.isEdit,
    required this.isAuthority,
    required this.loading,
    required this.isDark,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    // Authority → deep indigo-blue  /  Citizen → teal-blue
    final gradientColors = isAuthority
        ? [
            const Color(0xFF1E1B4B),
            const Color(0xFF312E81),
            const Color(0xFF2563EB),
          ]
        : [
            const Color(0xFF0F2850),
            const Color(0xFF1E40AF),
            const Color(0xFF0EA5E9),
          ];

    final roleColor = isAuthority
        ? const Color(0xFFA5B4FC)
        : const Color(0xFF7DD3FC);
    final roleLabel = isAuthority ? 'Authority' : 'Citizen';
    final roleIcon = isAuthority
        ? Icons.shield_outlined
        : Icons.person_outline_rounded;
    final actionLabel = isEdit
        ? (isAuthority ? 'Edit Authority' : 'Edit Citizen')
        : (isAuthority ? 'Create Authority' : 'Create Citizen');
    final actionSub = isEdit
        ? 'Update account details below'
        : 'Fill in the details to register a new ${isAuthority ? "authority" : "citizen"}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + loading
              Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (loading) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Loading…',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  // Admin badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.admin_panel_settings_outlined,
                          color: Colors.white70,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Admin Panel',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: roleColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(roleIcon, color: roleColor, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      roleLabel,
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                actionLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                actionSub,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section Card
// ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isDark;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B27) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : iconColor.withValues(alpha: 0.1),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 17, color: iconColor),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : iconColor.withValues(alpha: 0.08),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Admin Field
// ─────────────────────────────────────────────────────────────
class _AdminField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color accentColor;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _AdminField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : const Color(0xFF6B7280),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  icon,
                  size: 18,
                  color: accentColor.withValues(alpha: 0.8),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              suffixIcon: suffix != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: suffix,
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              hintText: 'Enter $label',
              hintStyle: TextStyle(
                color: isDark ? Colors.white24 : Colors.grey.shade400,
                fontSize: 13,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : accentColor.withValues(alpha: 0.03),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(
                  color: accentColor.withValues(alpha: 0.12),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : accentColor.withValues(alpha: 0.15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: accentColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFFDC2626)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: Color(0xFFDC2626),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Status Selector (replaces dropdown)
// ─────────────────────────────────────────────────────────────
class _StatusSelector extends StatelessWidget {
  final String value;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _StatusSelector({
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      (
        key: 'active',
        label: 'Active',
        sub: 'User can log in and use the app',
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF059669),
      ),
      (
        key: 'suspended',
        label: 'Suspended',
        sub: 'Account is temporarily disabled',
        icon: Icons.block_outlined,
        color: const Color(0xFFDC2626),
      ),
    ];

    return Column(
      children: options.map((opt) {
        final selected = value == opt.key;
        return GestureDetector(
          onTap: () => onChanged(opt.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected
                  ? opt.color.withValues(alpha: isDark ? 0.15 : 0.06)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : const Color(0xFFF9FAFB)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? opt.color.withValues(alpha: 0.5)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFE5E7EB)),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: opt.color.withValues(alpha: selected ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    opt.icon,
                    size: 19,
                    color: opt.color.withValues(alpha: selected ? 1 : 0.5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? opt.color
                              : (isDark
                                    ? Colors.white70
                                    : const Color(0xFF374151)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        opt.sub,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? opt.color : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? opt.color
                          : (isDark ? Colors.white24 : Colors.grey.shade300),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Submit Button
// ─────────────────────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  final bool isEdit;
  final bool submitting;
  final bool enabled;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.isEdit,
    required this.submitting,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: submitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isEdit ? Icons.save_outlined : Icons.person_add_outlined,
                    color: enabled ? Colors.white : Colors.grey.shade500,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEdit ? 'Save Changes' : 'Create User',
                    style: TextStyle(
                      color: enabled ? Colors.white : Colors.grey.shade500,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
