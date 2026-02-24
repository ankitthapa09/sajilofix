import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/api/api_client.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/core/services/app_permissions.dart';
import 'package:sajilofix/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:sajilofix/features/auth/domain/entities/auth_user.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  final AuthUser user;
  const ProfileEditPage({super.key, required this.user});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _districtController;
  late final TextEditingController _municipalityController;
  late final TextEditingController _wardController;
  late final TextEditingController _toleController;
  late final TextEditingController _dobController;
  late final TextEditingController _citizenshipController;

  bool _saving = false;
  Uint8List? _profileImageBytes;

  AnimationController? _animController;
  Animation<double> _fadeAnim = const AlwaysStoppedAnimation(1.0);

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

    final nameParts = _splitName(widget.user.fullName);
    _firstNameController = TextEditingController(text: nameParts.first);
    _lastNameController = TextEditingController(text: nameParts.last);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _districtController = TextEditingController(
      text: widget.user.district ?? '',
    );
    _municipalityController = TextEditingController(
      text: widget.user.municipality ?? '',
    );
    _wardController = TextEditingController(text: widget.user.ward ?? '');
    _toleController = TextEditingController(text: widget.user.tole ?? '');
    _dobController = TextEditingController(text: widget.user.dob ?? '');
    _citizenshipController = TextEditingController(
      text: widget.user.citizenshipNumber ?? '',
    );
  }

  @override
  void dispose() {
    _animController?.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _districtController.dispose();
    _municipalityController.dispose();
    _wardController.dispose();
    _toleController.dispose();
    _dobController.dispose();
    _citizenshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final apiBaseUrl = ref.read(apiClientProvider).dio.options.baseUrl;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Gradient App Bar ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: _EditHeader(
                initials: _initials(widget.user.fullName),
                photoBytes: _profileImageBytes,
                photoUrl: _profileImageBytes == null
                    ? _buildProfilePhotoUrl(
                        apiBaseUrl,
                        widget.user.profilePhoto,
                      )
                    : null,
                onPickPhoto: _pickProfilePhoto,
                onBack: () => Navigator.pop(context),
              ),
            ),

            // ── Form Body ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Info section
                      _SectionLabel(
                        label: 'Personal Info',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _FormCard(
                        isDark: isDark,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _ModernField(
                                  label: 'First Name',
                                  controller: _firstNameController,
                                  validator: _required,
                                  icon: Icons.badge_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ModernField(
                                  label: 'Last Name',
                                  controller: _lastNameController,
                                  validator: _required,
                                  icon: Icons.badge_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _ModernField(
                            label: 'Email Address',
                            controller: _emailController,
                            icon: Icons.email_outlined,
                            readOnly: true,
                            hint: 'Cannot be changed',
                          ),
                          const SizedBox(height: 14),
                          _ModernField(
                            label: 'Phone Number',
                            controller: _phoneController,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),
                          _ModernField(
                            label: 'Date of Birth',
                            controller: _dobController,
                            icon: Icons.calendar_month_outlined,
                            readOnly: true,
                            onTap: _pickDob,
                          ),
                          const SizedBox(height: 14),
                          _ModernField(
                            label: 'Citizenship No.',
                            controller: _citizenshipController,
                            icon: Icons.featured_play_list_outlined,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Address section
                      _SectionLabel(
                        label: 'Address',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 12),
                      _FormCard(
                        isDark: isDark,
                        children: [
                          _ModernField(
                            label: 'Tole / Street',
                            controller: _toleController,
                            icon: Icons.signpost_outlined,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _ModernField(
                                  label: 'Municipality',
                                  controller: _municipalityController,
                                  icon: Icons.location_city_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ModernField(
                                  label: 'Ward No.',
                                  controller: _wardController,
                                  icon: Icons.tag_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _ModernField(
                            label: 'District',
                            controller: _districtController,
                            icon: Icons.map_outlined,
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Save Button
                      _SaveButton(
                        saving: _saving,
                        onPressed: _saving ? null : _saveProfile,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pickers ──────────────────────────────────────────────────────────────

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial =
        _tryParseDate(_dobController.text) ??
        DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked == null) return;
    setState(() => _dobController.text = _formatDate(picked));
  }

  Future<void> _pickProfilePhoto() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BottomSheetOption(
                icon: Icons.photo_camera_outlined,
                label: 'Take a Photo',
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final ok = await AppPermissions.ensureCamera(context);
                  if (!context.mounted) return;
                  if (!ok) return;
                  await _pickAndUpload(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _BottomSheetOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose from Gallery',
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final ok = await AppPermissions.ensurePhotos(context);
                  if (!context.mounted) return;
                  if (!ok) return;
                  await _pickAndUpload(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (!mounted) return;
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _profileImageBytes = bytes);

      final apiClient = ref.read(apiClientProvider);
      final formData = FormData.fromMap({
        'photo': MultipartFile.fromBytes(
          bytes,
          filename: file.name.isNotEmpty ? file.name : 'profile.jpg',
        ),
      });

      await apiClient.uploadFile(
        ApiEndpoints.uploadProfilePhoto,
        formData: formData,
        method: 'PUT',
        options: Options(contentType: 'multipart/form-data'),
      );

      await _syncCurrentUserFromApi();
      if (!mounted) return;
      showMySnackBar(
        context: context,
        message: 'Profile photo updated.',
        icon: Icons.check_circle_outline,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data is Map)
          ? e.response?.data['message']?.toString()
          : null;
      showMySnackBar(
        context: context,
        message: msg ?? e.message ?? 'Failed to upload.',
        isError: true,
        icon: Icons.error_outline,
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      showMySnackBar(
        context: context,
        message: e.message ?? 'Unable to open camera/gallery.',
        isError: true,
        icon: Icons.error_outline,
      );
    } catch (e) {
      if (!mounted) return;
      showMySnackBar(
        context: context,
        message: 'Failed: $e',
        isError: true,
        icon: Icons.error_outline,
      );
    }
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final payload = _buildUpdatePayload();
      final apiClient = ref.read(apiClientProvider);
      await apiClient.patch(ApiEndpoints.updateMe, data: payload);
      await _syncCurrentUserFromApi();
      if (!mounted) return;
      showMySnackBar(
        context: context,
        message: 'Profile updated successfully.',
        icon: Icons.check_circle_outline,
      );
      Navigator.pop(context, true);
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data is Map)
          ? e.response?.data['message']?.toString()
          : null;
      showMySnackBar(
        context: context,
        message: msg ?? e.message ?? 'Failed to update profile.',
        isError: true,
        icon: Icons.error_outline,
      );
    } catch (e) {
      if (!mounted) return;
      showMySnackBar(
        context: context,
        message: 'Failed: $e',
        isError: true,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Map<String, dynamic> _buildUpdatePayload() {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final fullName = [first, last].where((v) => v.isNotEmpty).join(' ');
    final payload = <String, dynamic>{
      'fullName': fullName,
      'phone': _phoneController.text.trim(),
      'district': _districtController.text.trim(),
      'municipality': _municipalityController.text.trim(),
      'wardNumber': _wardController.text.trim(),
      'tole': _toleController.text.trim(),
      'dob': _normalizeDob(_dobController.text),
      'citizenshipNumber': _citizenshipController.text.trim(),
    };
    payload.removeWhere(
      (_, v) => v == null || (v is String && v.trim().isEmpty),
    );
    return payload;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'Required' : null;

  Future<void> _syncCurrentUserFromApi() async {
    try {
      final remote = ref.read(authRemoteDatasourceProvider);
      final local = ref.read(authLocalDataSourceProvider);
      final remoteUser = await remote.getMe();
      if (remoteUser == null) return;
      await local.upsertUserPreservePasswordHash(
        fullName: remoteUser.fullName,
        email: remoteUser.email,
        phone: (remoteUser.phone ?? '').trim(),
        roleIndex: remoteUser.roleIndex,
        dob: remoteUser.dob,
        citizenshipNumber: remoteUser.citizenshipNumber,
        district: remoteUser.district,
        municipality: remoteUser.municipality,
        ward: remoteUser.ward,
        tole: remoteUser.tole,
        profilePhoto: remoteUser.profilePhoto,
        createdAt: remoteUser.createdAt,
      );
      ref.invalidate(currentUserProvider);
    } catch (_) {}
  }

  static ({String first, String last}) _splitName(String? fullName) {
    final trimmed = (fullName ?? '').trim();
    if (trimmed.isEmpty) return (first: '', last: '');
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length == 1) return (first: parts[0], last: '');
    return (first: parts.first, last: parts.sublist(1).join(' '));
  }

  static String _initials(String? name) {
    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1)
      return parts.first.characters.take(2).toString().toUpperCase();
    return (parts.first.characters.first.toString() +
            parts.last.characters.first.toString())
        .toUpperCase();
  }

  static String? _buildProfilePhotoUrl(String baseUrl, String? profilePhoto) {
    final rel = (profilePhoto ?? '').trim();
    if (rel.isEmpty) return null;
    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanRel = rel.replaceAll(RegExp(r'^/+'), '');
    if (cleanRel.startsWith('uploads/')) return '$cleanBase/$cleanRel';
    return '$cleanBase/uploads/$cleanRel';
  }

  static String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString().padLeft(4, '0');
    return '$dd/$mm/$yyyy';
  }

  static DateTime? _tryParseDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (value.contains('/')) {
      final parts = value.split('/');
      if (parts.length == 3) {
        final dd = int.tryParse(parts[0]);
        final mm = int.tryParse(parts[1]);
        final yyyy = int.tryParse(parts[2]);
        if (dd != null && mm != null && yyyy != null)
          return DateTime(yyyy, mm, dd);
      }
    }
    return DateTime.tryParse(value);
  }

  static String _normalizeDob(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return value;
    if (value.contains('/')) {
      final parts = value.split('/');
      if (parts.length == 3) {
        final dd = int.tryParse(parts[0]);
        final mm = int.tryParse(parts[1]);
        final yyyy = int.tryParse(parts[2]);
        if (dd != null && mm != null && yyyy != null) {
          return '${yyyy.toString().padLeft(4, '0')}-${mm.toString().padLeft(2, '0')}-${dd.toString().padLeft(2, '0')}';
        }
      }
    }
    return value;
  }
}

// ─────────────────────────────────────────────────────────────
// Edit Header (gradient banner + avatar)
// ─────────────────────────────────────────────────────────────
class _EditHeader extends StatelessWidget {
  final String initials;
  final Uint8List? photoBytes;
  final String? photoUrl;
  final VoidCallback onPickPhoto;
  final VoidCallback onBack;

  const _EditHeader({
    required this.initials,
    required this.photoBytes,
    required this.photoUrl,
    required this.onPickPhoto,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    final gradientColors = isDark
        ? [const Color(0xFF1A2236), const Color(0xFF111827)]
        : [const Color(0xFF1D4ED8), const Color(0xFF2563EB)];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 28),
            child: Column(
              children: [
                // Top bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Edit Profile',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Avatar with camera button
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(child: _avatarContent(theme)),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: GestureDetector(
                        onTap: onPickPhoto,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2563EB),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.photo_camera,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap the camera to change photo',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarContent(ThemeData theme) {
    if (photoBytes != null) {
      return Image.memory(
        photoBytes!,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    }
    final url = (photoUrl ?? '').trim();
    if (url.isNotEmpty) {
      return Image.network(
        url,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialsWidget(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          );
        },
      );
    }
    return _initialsWidget();
  }

  Widget _initialsWidget() {
    return Container(
      width: 90,
      height: 90,
      color: Colors.white.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 15, color: const Color(0xFF2563EB)),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2563EB),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Form Card (groups fields)
// ─────────────────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;

  const _FormCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Modern Field
// ─────────────────────────────────────────────────────────────
class _ModernField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final bool readOnly;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;

  const _ModernField({
    required this.label,
    required this.controller,
    this.icon,
    this.readOnly = false,
    this.hint,
    this.validator,
    this.keyboardType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onTap: onTap,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: readOnly
                ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
                : theme.colorScheme.onSurface.withValues(alpha: 0.9),
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            filled: true,
            fillColor: readOnly
                ? theme.colorScheme.onSurface.withValues(alpha: 0.04)
                : isDark
                ? theme.colorScheme.surface
                : const Color(0xFFF8FAFC),
            prefixIcon: icon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      icon,
                      size: 18,
                      color: readOnly
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                          : const Color(0xFF2563EB),
                    ),
                  ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: theme.dividerColor.withValues(
                  alpha: readOnly ? 0.08 : 0.2,
                ),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF93C5FD),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: theme.colorScheme.error.withValues(alpha: 0.6),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Save Button
// ─────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final bool saving;
  final VoidCallback? onPressed;

  const _SaveButton({required this.saving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: onPressed == null
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.withValues(alpha: 0.2),
            disabledForegroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Save Changes',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom Sheet Option
// ─────────────────────────────────────────────────────────────
class _BottomSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomSheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
