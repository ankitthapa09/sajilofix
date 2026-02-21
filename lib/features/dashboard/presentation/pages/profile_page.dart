import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/api/api_client.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/core/services/app_permissions.dart';
import 'package:sajilofix/core/widgets/gradiant_elevated_button.dart';
import 'package:sajilofix/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:sajilofix/features/auth/domain/entities/auth_user.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/dashboard/presentation/pages/profile_edit_page.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  Uint8List? _profileImageBytes;
  AnimationController? _animController;
  Animation<double> _fadeAnim = const AlwaysStoppedAnimation(1.0);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeOut,
    );
    _animController!.forward();

    Future.microtask(() async {
      await _syncCurrentUserFromApi();
      if (!mounted) return;
      ref.invalidate(currentUserProvider);
    });
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

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
    } catch (_) {}
  }

  String? _buildProfilePhotoUrl(String baseUrl, String? profilePhoto) {
    final rel = (profilePhoto ?? '').trim();
    if (rel.isEmpty) return null;
    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanRel = rel.replaceAll(RegExp(r'^/+'), '');
    if (cleanRel.startsWith('uploads/')) return '$cleanBase/$cleanRel';
    return '$cleanBase/uploads/$cleanRel';
  }

  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  bool _shareUsageData = false;
  bool _locationServices = true;
  bool _biometricLock = false;
  bool _autoLogout = false;

  Future<void> _uploadProfilePhoto({
    required XFile file,
    required Uint8List bytes,
  }) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      showMySnackBar(
        context: context,
        message: 'Uploading photo…',
        icon: Icons.cloud_upload_outlined,
      );
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
      ref.invalidate(currentUserProvider);
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
        message: msg ?? e.message ?? 'Upload failed.',
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

  Future<void> _pickAndSetProfileImage(ImageSource source) async {
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
      await _uploadProfilePhoto(file: file, bytes: bytes);
    } on MissingPluginException {
      if (!mounted) return;
      showMySnackBar(
        context: context,
        message: 'Not available on this platform.',
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
        message: 'Failed to pick image: $e',
        isError: true,
        icon: Icons.error_outline,
      );
    }
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
                  await _pickAndSetProfileImage(ImageSource.camera);
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
                  await _pickAndSetProfileImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
      ref.invalidate(currentUserProvider);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } catch (e) {
      if (!mounted) return;
      showMySnackBar(context: context, message: e.toString());
    }
  }

  void _goToTab(int index) {
    Navigator.of(
      context,
    ).pushReplacementNamed(AppRoutes.dashboard, arguments: index);
  }

  Future<void> _openProfileEdit(AuthUser user) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProfileEditPage(user: user)),
    );
    if (updated == true && mounted) {
      await _syncCurrentUserFromApi();
      ref.invalidate(currentUserProvider);
    }
  }

  String _initials(String? name) {
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

  String _address({
    required String? tole,
    required String? ward,
    required String? municipality,
    required String? district,
  }) {
    final pieces = <String>[];
    if ((tole ?? '').trim().isNotEmpty) pieces.add(tole!.trim());
    if ((ward ?? '').trim().isNotEmpty) pieces.add('Ward ${ward!.trim()}');
    if ((municipality ?? '').trim().isNotEmpty)
      pieces.add(municipality!.trim());
    if ((district ?? '').trim().isNotEmpty) pieces.add(district!.trim());
    return pieces.isEmpty ? '—' : pieces.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user session. Please log in.'));
          }

          final address = _address(
            tole: user.tole,
            ward: user.ward,
            municipality: user.municipality,
            district: user.district,
          );
          final apiBaseUrl = ref.read(apiClientProvider).dio.options.baseUrl;

          return FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Hero Header
                SliverToBoxAdapter(
                  child: _HeroHeader(
                    initials: _initials(user.fullName),
                    fullName: user.fullName.isEmpty ? 'User' : user.fullName,
                    email: user.email,
                    photoBytes: _profileImageBytes,
                    photoUrl: _profileImageBytes == null
                        ? _buildProfilePhotoUrl(apiBaseUrl, user.profilePhoto)
                        : null,
                    onPickPhoto: _pickProfilePhoto,
                    onEditProfile: () => _openProfileEdit(user),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // Quick Actions
                        _QuickActionsRow(
                          onHome: () => _goToTab(0),
                          onReport: () => _goToTab(1),
                          onMyReports: () => _goToTab(2),
                        ),
                        const SizedBox(height: 24),

                        // Settings Menu
                        _SettingsMenuCard(
                          tabIndex: _tabIndex,
                          onTabChanged: (i) => setState(() => _tabIndex = i),
                        ),
                        const SizedBox(height: 16),

                        // Section Content
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: _buildSection(theme),
                        ),
                        const SizedBox(height: 24),

                        // Logout
                        _LogoutButton(onLogout: _logout),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(ThemeData theme) {
    switch (_tabIndex) {
      case 1:
        return _NotificationsSection(
          key: const ValueKey(1),
          pushNotifications: _pushNotifications,
          emailNotifications: _emailNotifications,
          smsNotifications: _smsNotifications,
          onPushChanged: (v) => setState(() => _pushNotifications = v),
          onEmailChanged: (v) => setState(() => _emailNotifications = v),
          onSmsChanged: (v) => setState(() => _smsNotifications = v),
          onOpenSettings: () => showMySnackBar(
            context: context,
            message: 'Notification settings coming soon',
          ),
        );
      case 2:
        return _PrivacySection(
          key: const ValueKey(2),
          shareUsageData: _shareUsageData,
          locationServices: _locationServices,
          onShareUsageChanged: (v) => setState(() => _shareUsageData = v),
          onLocationChanged: (v) => setState(() => _locationServices = v),
          onManagePermissions: () => showMySnackBar(
            context: context,
            message: 'Permissions screen coming soon',
          ),
        );
      case 3:
        return _SecuritySection(
          key: const ValueKey(3),
          biometricLock: _biometricLock,
          autoLogout: _autoLogout,
          onBiometricChanged: (v) => setState(() => _biometricLock = v),
          onAutoLogoutChanged: (v) => setState(() => _autoLogout = v),
          onChangePassword: () => showMySnackBar(
            context: context,
            message: 'Change password coming soon',
          ),
        );
      default:
        return const SizedBox.shrink(key: ValueKey(0));
    }
  }
}

class _HeroHeader extends StatelessWidget {
  final String initials;
  final String fullName;
  final String email;
  final Uint8List? photoBytes;
  final String? photoUrl;
  final VoidCallback onPickPhoto;
  final VoidCallback onEditProfile;

  const _HeroHeader({
    required this.initials,
    required this.fullName,
    required this.email,
    required this.photoBytes,
    required this.photoUrl,
    required this.onPickPhoto,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    final gradientColors = isDark
        ? [const Color(0xFF1A2236), const Color(0xFF111827)]
        : [const Color(0xFF2563EB), const Color(0xFF1E40AF)];

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
            top: -30,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Profile',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    GestureDetector(
                      onTap: onEditProfile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Edit',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
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
                            color: const Color(0xFF1D4ED8),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.photo_camera,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text(
                  fullName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Account Status: Active',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF86EFAC),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
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
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
    final url = (photoUrl ?? '').trim();
    if (url.isNotEmpty) {
      return Image.network(
        url,
        width: 100,
        height: 100,
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
      width: 100,
      height: 100,
      color: Colors.white.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -1,
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onReport;
  final VoidCallback onMyReports;

  const _QuickActionsRow({
    required this.onHome,
    required this.onReport,
    required this.onMyReports,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.home_rounded,
            label: 'Home',
            color: const Color(0xFF2563EB),
            onTap: onHome,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAction(
            icon: Icons.add_circle_outline_rounded,
            label: 'Report',
            color: const Color(0xFF059669),
            onTap: onReport,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAction(
            icon: Icons.assignment_rounded,
            label: 'My Reports',
            color: const Color(0xFFD97706),
            onTap: onMyReports,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.12)),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsMenuCard extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  const _SettingsMenuCard({required this.tabIndex, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = [
      (icon: Icons.notifications_outlined, label: 'Notifications', index: 1),
      (icon: Icons.privacy_tip_outlined, label: 'Privacy', index: 2),
      (icon: Icons.lock_outline, label: 'Security', index: 3),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.12)),
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
        children: items.map((item) {
          final isSelected = tabIndex == item.index;
          final isLast = item.index == items.last.index;
          return Column(
            children: [
              InkWell(
                onTap: () => onTabChanged(isSelected ? 0 : item.index),
                borderRadius: BorderRadius.circular(22),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2563EB).withValues(alpha: 0.06)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          item.icon,
                          size: 18,
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.8,
                                  ),
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: isSelected ? 0.25 : 0,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 70,
                  color: theme.dividerColor.withValues(alpha: 0.12),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Log Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.errorContainer,
          foregroundColor: theme.colorScheme.onErrorContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

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

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.12)),
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2563EB), size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
          ...children,
        ],
      ),
    );
  }
}

class _NotificationsSection extends StatelessWidget {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final ValueChanged<bool> onPushChanged;
  final ValueChanged<bool> onEmailChanged;
  final ValueChanged<bool> onSmsChanged;
  final VoidCallback onOpenSettings;

  const _NotificationsSection({
    super.key,
    required this.pushNotifications,
    required this.emailNotifications,
    required this.smsNotifications,
    required this.onPushChanged,
    required this.onEmailChanged,
    required this.onSmsChanged,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      icon: Icons.notifications_outlined,
      title: 'Notifications',
      children: [
        SwitchListTile.adaptive(
          value: pushNotifications,
          onChanged: onPushChanged,
          title: const Text('Push notifications'),
          subtitle: const Text('Alerts for updates and reports'),
        ),
        SwitchListTile.adaptive(
          value: emailNotifications,
          onChanged: onEmailChanged,
          title: const Text('Email updates'),
          subtitle: const Text('Important updates by email'),
        ),
        SwitchListTile.adaptive(
          value: smsNotifications,
          onChanged: onSmsChanged,
          title: const Text('SMS notifications'),
          subtitle: const Text('Critical alerts via SMS'),
        ),
        ListTile(
          onTap: onOpenSettings,
          title: const Text('Advanced settings'),
          subtitle: const Text('Sound, vibration, quiet hours'),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _PrivacySection extends StatelessWidget {
  final bool shareUsageData;
  final bool locationServices;
  final ValueChanged<bool> onShareUsageChanged;
  final ValueChanged<bool> onLocationChanged;
  final VoidCallback onManagePermissions;

  const _PrivacySection({
    super.key,
    required this.shareUsageData,
    required this.locationServices,
    required this.onShareUsageChanged,
    required this.onLocationChanged,
    required this.onManagePermissions,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      icon: Icons.privacy_tip_outlined,
      title: 'Privacy',
      children: [
        SwitchListTile.adaptive(
          value: locationServices,
          onChanged: onLocationChanged,
          title: const Text('Location services'),
          subtitle: const Text('Better report accuracy'),
        ),
        SwitchListTile.adaptive(
          value: shareUsageData,
          onChanged: onShareUsageChanged,
          title: const Text('Share usage data'),
          subtitle: const Text('Help improve SajiloFix'),
        ),
        ListTile(
          onTap: onManagePermissions,
          title: const Text('Manage permissions'),
          subtitle: const Text('Camera, storage, location'),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _SecuritySection extends StatelessWidget {
  final bool biometricLock;
  final bool autoLogout;
  final ValueChanged<bool> onBiometricChanged;
  final ValueChanged<bool> onAutoLogoutChanged;
  final VoidCallback onChangePassword;

  const _SecuritySection({
    super.key,
    required this.biometricLock,
    required this.autoLogout,
    required this.onBiometricChanged,
    required this.onAutoLogoutChanged,
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      icon: Icons.lock_outline,
      title: 'Security',
      children: [
        ListTile(
          onTap: onChangePassword,
          title: const Text('Change password'),
          subtitle: const Text('Update your account password'),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
        SwitchListTile.adaptive(
          value: biometricLock,
          onChanged: onBiometricChanged,
          title: const Text('Biometric lock'),
          subtitle: const Text('Fingerprint / face unlock'),
        ),
        SwitchListTile.adaptive(
          value: autoLogout,
          onChanged: onAutoLogoutChanged,
          title: const Text('Auto logout'),
          subtitle: const Text('Log out after inactivity'),
        ),
      ],
    );
  }
}
