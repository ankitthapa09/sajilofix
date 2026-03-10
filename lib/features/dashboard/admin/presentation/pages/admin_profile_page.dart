import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/app/theme/theme_mode_controller.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/core/constants/hero_tags.dart';
import 'package:sajilofix/core/services/biometrics/biometric_service.dart';
import 'package:sajilofix/core/services/storage/app_preferences.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/widgets/profile_widgets.dart';
import 'package:sajilofix/features/notifications/presentation/providers/notification_providers.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  bool _biometricLock = false;
  bool _autoDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSecurityPreferences();
  }

  Future<void> _loadSecurityPreferences() async {
    final enabled = await AppPreferences.isBiometricEnabled(roleIndex: 1);
    final autoDark = await AppPreferences.isAutoDarkModeEnabled();
    if (!mounted) return;
    setState(() {
      _biometricLock = enabled;
      _autoDarkMode = autoDark;
    });
  }

  Future<void> _toggleBiometric(bool enabled) async {
    if (enabled) {
      final ok = await BiometricService().authenticate(
        reason: 'Confirm to enable biometric login',
      );
      if (!mounted) return;
      if (!ok) {
        showMySnackBar(
          context: context,
          message: 'Biometric authentication failed',
          isError: true,
        );
        return;
      }
    }

    setState(() => _biometricLock = enabled);
    await AppPreferences.setBiometricEnabled(roleIndex: 1, enabled: enabled);
  }

  Future<void> _toggleAutoDarkMode(bool enabled) async {
    setState(() => _autoDarkMode = enabled);
    await ref.read(appThemeModeProvider.notifier).setAutoDarkMode(enabled);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1117)
          : const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Hero(
                    tag: HeroTags.appLogo,
                    child: Image.asset(
                      'assets/images/sajilofix_logo.png',
                      height: 60,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: currentUserAsync.maybeWhen(
                data: (user) => _ProfileHeader(
                  name: user?.fullName ?? 'Admin',
                  email: user?.email ?? 'admin@sajilofix.com',
                  photoUrl: _buildProfilePhotoUrl(user?.profilePhoto),
                ),
                orElse: () => const _ProfileHeader(
                  name: 'Admin',
                  email: 'admin@sajilofix.com',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                children: [
                  _ProfileActionTile(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Admin settings',
                    subtitle: 'Permissions, roles, and approvals',
                    onTap: () {
                      showMySnackBar(
                        context: context,
                        message: 'Admin settings coming soon',
                      );
                    },
                  ),
                  _ProfileActionTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Notifications',
                    subtitle: 'Review alerts and reminders',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.notifications),
                  ),
                  BiometricOnlySection(
                    biometricLock: _biometricLock,
                    onBiometricChanged: _toggleBiometric,
                  ),
                  AutoDarkModeSection(
                    autoDarkMode: _autoDarkMode,
                    onAutoDarkModeChanged: _toggleAutoDarkMode,
                  ),
                  const SizedBox(height: 8),
                  _ProfileActionTile(
                    icon: Icons.logout,
                    title: 'Log out',
                    subtitle: 'Sign out of admin session',
                    onTap: () async {
                      await ref.read(authRepositoryProvider).logout();
                      ref.invalidate(currentUserProvider);
                      ref.invalidate(adminIssuesControllerProvider);
                      ref.invalidate(unreadCountProvider);
                      ref.invalidate(notificationsControllerProvider);
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.adminLogin,
                        (route) => false,
                      );
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _buildProfilePhotoUrl(String? profilePhoto) {
    final rel = (profilePhoto ?? '').trim();
    if (rel.isEmpty) return null;
    final base = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final clean = rel.replaceAll(RegExp(r'^/+'), '');
    if (clean.startsWith('uploads/')) return '$base/$clean';
    return '$base/uploads/$clean';
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;

  const _ProfileHeader({
    required this.name,
    required this.email,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            backgroundImage: (photoUrl ?? '').trim().isNotEmpty
                ? NetworkImage(photoUrl!)
                : null,
            child: (photoUrl ?? '').trim().isNotEmpty
                ? null
                : Text(
                    _initials(name),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.first.toString() +
            parts.last.characters.first.toString())
        .toUpperCase();
  }
}

class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? const Color(0xFFEF4444)
        : theme.colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: theme.colorScheme.surface,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
