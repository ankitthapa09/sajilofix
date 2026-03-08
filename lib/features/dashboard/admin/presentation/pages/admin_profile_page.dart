import 'package:flutter/material.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/constants/hero_tags.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    onTap: () {
                      showMySnackBar(
                        context: context,
                        message: 'Notifications coming soon',
                      );
                    },
                  ),
                  _ProfileActionTile(
                    icon: Icons.security_outlined,
                    title: 'Security',
                    subtitle: 'Password and device protection',
                    onTap: () {
                      showMySnackBar(
                        context: context,
                        message: 'Security options coming soon',
                      );
                    },
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
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHeader({required this.name, required this.email});

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
            child: Icon(
              Icons.admin_panel_settings,
              color: theme.colorScheme.primary,
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
