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

class _AdminUserFormPageState extends ConsumerState<AdminUserFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  bool _showPassword = false;

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

  bool get _isEdit => widget.user != null;
  bool get _isAuthority => widget.role == 'authority';

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: '');
    _wardController = TextEditingController(text: '');
    _municipalityController = TextEditingController(text: '');
    _departmentController = TextEditingController(text: user?.department ?? '');
    _districtController = TextEditingController(text: '');
    _toleController = TextEditingController(text: '');
    _dobController = TextEditingController(text: '');
    _citizenshipController = TextEditingController(text: '');
    _passwordController = TextEditingController();
    _status = user?.status ?? 'active';
  }

  @override
  void dispose() {
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_submitting) return;

    setState(() => _submitting = true);

    try {
      final controller = ref.read(adminUsersControllerProvider.notifier);
      if (_isEdit) {
        final fullName = _nullIfEmpty(_fullNameController.text);
        final email = _nullIfEmpty(_emailController.text);
        final password = _nullIfEmpty(_passwordController.text);
        final phone = _nullIfEmpty(_phoneController.text);
        final wardNumber = _nullIfEmpty(_wardController.text);
        final municipality = _nullIfEmpty(_municipalityController.text);
        final department = _nullIfEmpty(_departmentController.text);
        final district = _nullIfEmpty(_districtController.text);
        final tole = _nullIfEmpty(_toleController.text);
        final dob = _nullIfEmpty(_dobController.text);
        final citizenship = _nullIfEmpty(_citizenshipController.text);

        if (_isAuthority) {
          await controller.updateAuthority(
            id: widget.user!.id,
            fullName: fullName,
            email: email,
            password: password,
            phone: phone,
            wardNumber: wardNumber,
            municipality: municipality,
            department: department,
            status: _status,
          );
        } else {
          await controller.updateCitizen(
            id: widget.user!.id,
            fullName: fullName,
            email: email,
            password: password,
            phone: phone,
            wardNumber: wardNumber,
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
          await controller.createAuthority(
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
          await controller.createCitizen(
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
      Navigator.pop(context, true);
      showMySnackBar(
        context: context,
        message: _isEdit ? 'User updated.' : 'User created.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit
              ? (_isAuthority ? 'Edit Authority' : 'Edit Citizen')
              : (_isAuthority ? 'Create Authority' : 'Create Citizen'),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _SectionTitle(title: 'Basic Details'),
              _Field(
                controller: _fullNameController,
                label: 'Full Name',
                validator: _required,
              ),
              _Field(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: _required,
              ),
              _Field(
                controller: _phoneController,
                label: 'Phone',
                keyboardType: TextInputType.phone,
                validator: _required,
              ),
              _Field(
                controller: _wardController,
                label: 'Ward Number',
                keyboardType: TextInputType.number,
                validator: _required,
              ),
              _Field(
                controller: _municipalityController,
                label: 'Municipality',
                validator: _required,
              ),
              if (_isAuthority)
                _Field(
                  controller: _departmentController,
                  label: 'Department',
                  validator: _required,
                ),
              if (!_isAuthority) ...[
                _Field(controller: _districtController, label: 'District'),
                _Field(controller: _toleController, label: 'Tole'),
                _Field(controller: _dobController, label: 'DOB (YYYY-MM-DD)'),
                _Field(
                  controller: _citizenshipController,
                  label: 'Citizenship Number',
                ),
              ],
              _SectionTitle(title: 'Security'),
              _Field(
                controller: _passwordController,
                label: _isEdit ? 'New Password (optional)' : 'Password',
                obscureText: !_showPassword,
                validator: _isEdit ? null : _required,
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              _SectionTitle(title: 'Status'),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(
                    value: 'suspended',
                    child: Text('Suspended'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _status = value);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEdit ? 'Save Changes' : 'Create User'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'This field is required';
    return null;
  }

  String? _nullIfEmpty(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? null : v;
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(labelText: label, suffixIcon: suffix),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
