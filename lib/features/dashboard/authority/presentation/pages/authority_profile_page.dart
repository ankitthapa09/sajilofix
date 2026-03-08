import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/constants/hero_tags.dart';
import 'package:sajilofix/core/services/biometrics/biometric_service.dart';
import 'package:sajilofix/core/services/storage/app_preferences.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/dashboard/authority/presentation/providers/authority_issues_providers.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/widgets/profile_widgets.dart';
import 'package:sajilofix/features/notifications/presentation/providers/notification_providers.dart';

class AuthorityProfileScreen extends ConsumerStatefulWidget {
  const AuthorityProfileScreen({super.key});

  @override
  ConsumerState<AuthorityProfileScreen> createState() =>
      _AuthorityProfileScreenState();
}

class _AuthorityProfileScreenState
    extends ConsumerState<AuthorityProfileScreen> {
  bool _biometricLock = false;

  @override
  void initState() {
    super.initState();
    _loadSecurityPreferences();
  }

  Future<void> _loadSecurityPreferences() async {
    final enabled = await AppPreferences.isBiometricEnabled(roleIndex: 2);
    if (!mounted) return;
    setState(() => _biometricLock = enabled);
  }

  Future<void> _toggleBiometric(bool enabled) async {
    if (enabled) {
      final ok = await BiometricService().authenticate(
        reason: 'Confirm to enable biometric login',
      );
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
    await AppPreferences.setBiometricEnabled(roleIndex: 2, enabled: enabled);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final userAsync = ref.watch(currentUserProvider);

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
                    icon: Icon(Icons.settings_outlined, color: onSurface),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: userAsync.maybeWhen(
                data: (user) => _ProfileHeader(
                  name: user?.fullName ?? 'Authority',
                  email: user?.email ?? 'authority@sajilofix.gov.np',
                ),
                orElse: () => const _ProfileHeader(
                  name: 'Authority',
                  email: 'authority@sajilofix.gov.np',
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                children: [
                  _ProfileActionTile(
                    icon: Icons.shield_outlined,
                    title: 'Authority settings',
                    subtitle: 'Coverage, shifts, and department',
                    onTap: () => showMySnackBar(
                      context: context,
                      message: 'Authority settings coming soon',
                    ),
                  ),
                  _ProfileActionTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Alerts',
                    subtitle: 'Issue alerts and reminders',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.notifications),
                  ),
                  BiometricOnlySection(
                    biometricLock: _biometricLock,
                    onBiometricChanged: _toggleBiometric,
                  ),
                  const SizedBox(height: 8),
                  _ProfileActionTile(
                    icon: Icons.logout,
                    title: 'Log out',
                    subtitle: 'Sign out of authority session',
                    onTap: () async {
                      await ref.read(authRepositoryProvider).logout();
                      ref.invalidate(currentUserProvider);
                      ref.invalidate(authorityIssuesControllerProvider);
                      ref.invalidate(unreadCountProvider);
                      ref.invalidate(notificationsControllerProvider);
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
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
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE9ECF2),
        ),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.18),
            child: Icon(Icons.person_rounded, color: onSurface),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.6);
    final tone = isDestructive ? const Color(0xFFEF4444) : onSurface;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE9ECF2),
        ),
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
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: tone),
        title: Text(
          title,
          style: TextStyle(color: tone, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: muted, fontSize: 12)),
        trailing: Icon(Icons.chevron_right_rounded, color: muted),
      ),
    );
  }
}
