import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/api/api_client.dart';
import 'package:sajilofix/core/services/app_permissions.dart';
import 'package:sajilofix/features/auth/domain/entities/auth_user.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/providers/citizen_home_providers.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/providers/citizen_profile_providers.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/pages/profile_edit_page.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/widgets/profile_widgets.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';

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
      await ref
          .read(citizenProfileControllerProvider.notifier)
          .syncCurrentUser();
    });
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
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
      await ref
          .read(citizenProfileControllerProvider.notifier)
          .uploadProfilePhoto(formData: formData);
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
              ProfileBottomSheetOption(
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
              ProfileBottomSheetOption(
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
      ref.invalidate(myReportsProvider);
      ref.invalidate(citizenHomeStatsProvider);
      ref.invalidate(adminIssuesControllerProvider);
      ref.read(reportFormDraftProvider.notifier).reset();
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
      await ref
          .read(citizenProfileControllerProvider.notifier)
          .syncCurrentUser();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserAsync = ref.watch(currentUserProvider);
    final profileState = ref.watch(citizenProfileControllerProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user session. Please log in.'));
          }

          final apiBaseUrl = ref.read(apiClientProvider).dio.options.baseUrl;

          return FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Hero Header
                SliverToBoxAdapter(
                  child: ProfileHeroHeader(
                    initials: _initials(user.fullName),
                    fullName: user.fullName.isEmpty ? 'User' : user.fullName,
                    email: user.email,
                    photoBytes: _profileImageBytes,
                    photoUrl: _profileImageBytes == null
                        ? _buildProfilePhotoUrl(apiBaseUrl, user.profilePhoto)
                        : null,
                    status: profileState.status,
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
                        ProfileQuickActionsRow(
                          onHome: () => _goToTab(0),
                          onReport: () => _goToTab(1),
                          onMyReports: () => _goToTab(2),
                        ),
                        const SizedBox(height: 24),

                        // Settings Menu
                        ProfileSettingsMenuCard(
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
                        ProfileLogoutButton(onLogout: _logout),
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
        return ProfileNotificationsSection(
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
        return ProfilePrivacySection(
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
        return ProfileSecuritySection(
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
