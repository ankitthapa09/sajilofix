import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/widgets/gradiant_elevated_button.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _tabIndex = 0; // 0 Profile, 1 Notifications, 2 Privacy, 3 Security

  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;

  bool _shareUsageData = false;
  bool _locationServices = true;

  bool _biometricLock = false;
  bool _autoLogout = false;

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

  String _initials(String? name) {
    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return 'U';

    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final list = parts.toList();

    if (list.isEmpty) return 'U';
    if (list.length == 1) {
      return list.first.characters.take(2).toString().toUpperCase();
    }

    final first = list.first.characters.first.toString();
    final last = list.last.characters.first.toString();
    return (first + last).toUpperCase();
  }

  ({String first, String last}) _splitName(String? fullName) {
    final trimmed = (fullName ?? '').trim();
    if (trimmed.isEmpty) return (first: '', last: '');

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return (first: parts[0], last: '');
    }

    return (first: parts.first, last: parts.sublist(1).join(' '));
  }

  String _address({
    required String? tole,
    required String? ward,
    required String? municipality,
    required String? district,
  }) {
    final pieces = <String>[];

    if ((tole ?? '').trim().isNotEmpty) {
      pieces.add(tole!.trim());
    }
    if ((ward ?? '').trim().isNotEmpty) {
      pieces.add('Ward ${ward!.trim()}');
    }
    if ((municipality ?? '').trim().isNotEmpty) {
      pieces.add(municipality!.trim());
    }
    if ((district ?? '').trim().isNotEmpty) {
      pieces.add(district!.trim());
    }

    return pieces.isEmpty ? '-' : pieces.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: currentUserAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.only(top: 24),
              child: _InfoBanner(
                icon: Icons.error_outline,
                title: 'Unable to load profile',
                subtitle: e.toString(),
              ),
            ),
            data: (user) {
              if (user == null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _InfoBanner(
                    icon: Icons.person_outline,
                    title: 'No user session',
                    subtitle: 'Please log in to view your profile.',
                  ),
                );
              }

              final nameParts = _splitName(user.fullName);
              final address = _address(
                tole: user.tole,
                ward: user.ward,
                municipality: user.municipality,
                district: user.district,
              );

              final sectionWidget = switch (_tabIndex) {
                1 => _NotificationsSection(
                  pushNotifications: _pushNotifications,
                  emailNotifications: _emailNotifications,
                  smsNotifications: _smsNotifications,
                  onPushChanged: (v) => setState(() => _pushNotifications = v),
                  onEmailChanged: (v) =>
                      setState(() => _emailNotifications = v),
                  onSmsChanged: (v) => setState(() => _smsNotifications = v),
                  onOpenSettings: () => showMySnackBar(
                    context: context,
                    message: 'Notification settings not implemented yet',
                  ),
                ),
                2 => _PrivacySection(
                  shareUsageData: _shareUsageData,
                  locationServices: _locationServices,
                  onShareUsageChanged: (v) =>
                      setState(() => _shareUsageData = v),
                  onLocationChanged: (v) =>
                      setState(() => _locationServices = v),
                  onManagePermissions: () => showMySnackBar(
                    context: context,
                    message: 'Permissions screen not implemented yet',
                  ),
                ),
                3 => _SecuritySection(
                  biometricLock: _biometricLock,
                  autoLogout: _autoLogout,
                  onBiometricChanged: (v) => setState(() => _biometricLock = v),
                  onAutoLogoutChanged: (v) => setState(() => _autoLogout = v),
                  onChangePassword: () => showMySnackBar(
                    context: context,
                    message: 'Change password not implemented yet',
                  ),
                ),
                _ => _ProfileDetailsCard(
                  firstName: nameParts.first,
                  lastName: nameParts.last,
                  email: user.email,
                  phone: user.phone,
                  address: address,
                  dob: (user.dob ?? '').trim(),
                ),
              };

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHeaderCard(
                    initials: _initials(user.fullName),
                    fullName: user.fullName.isEmpty ? 'User' : user.fullName,
                    email: user.email,
                    onPickPhoto: () {
                      showMySnackBar(
                        context: context,
                        message: 'Upload photo not implemented yet',
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _QuickActionsGrid(
                    onHome: () => _goToTab(0),
                    onReport: () => _goToTab(1),
                    onMyReports: () => _goToTab(2),
                    onProfile: () => _goToTab(3),
                  ),
                  const SizedBox(height: 18),
                  _MenuItem(
                    title: 'Profile',
                    selected: _tabIndex == 0,
                    onTap: () => setState(() => _tabIndex = 0),
                  ),
                  const SizedBox(height: 10),
                  _MenuItem(
                    title: 'Notification',
                    selected: _tabIndex == 1,
                    onTap: () => setState(() => _tabIndex = 1),
                  ),
                  const SizedBox(height: 10),
                  _MenuItem(
                    title: 'Privacy',
                    selected: _tabIndex == 2,
                    onTap: () => setState(() => _tabIndex = 2),
                  ),
                  const SizedBox(height: 10),
                  _MenuItem(
                    title: 'Security',
                    selected: _tabIndex == 3,
                    onTap: () => setState(() => _tabIndex = 3),
                  ),
                  const SizedBox(height: 18),
                  sectionWidget,
                  const SizedBox(height: 18),
                  GradientElevatedButton(
                    text: 'Logout',
                    height: 52,
                    borderRadius: 16,
                    onPressed: _logout,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final String initials;
  final String fullName;
  final String email;
  final VoidCallback onPickPhoto;

  const _ProfileHeaderCard({
    required this.initials,
    required this.fullName,
    required this.email,
    required this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: InkWell(
                  onTap: onPickPhoto,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surface,
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Icon(
                      Icons.photo_camera_outlined,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onReport;
  final VoidCallback onMyReports;
  final VoidCallback onProfile;

  const _QuickActionsGrid({
    required this.onHome,
    required this.onReport,
    required this.onMyReports,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                title: 'Home',
                icon: Icons.home_rounded,
                onTap: onHome,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                title: 'Report',
                icon: Icons.camera_alt_rounded,
                onTap: onReport,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                title: 'My Reports',
                icon: Icons.assignment_rounded,
                onTap: onMyReports,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                title: 'Profile',
                icon: Icons.person_rounded,
                onTap: onProfile,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _MenuItem({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetailsCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String dob;

  const _ProfileDetailsCard({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.dob,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                'Profile Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ReadOnlyField(
                  label: 'First Name',
                  value: firstName.trim().isEmpty ? '-' : firstName.trim(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReadOnlyField(
                  label: 'Last Name',
                  value: lastName.trim().isEmpty ? '-' : lastName.trim(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ReadOnlyField(
            label: 'Email Address',
            value: email,
            leading: Icons.email_outlined,
          ),
          const SizedBox(height: 12),
          _ReadOnlyField(
            label: 'Phone Number',
            value: phone.trim().isEmpty ? '-' : phone.trim(),
            leading: Icons.phone_outlined,
          ),
          const SizedBox(height: 12),
          _ReadOnlyField(
            label: 'Address',
            value: address.trim().isEmpty ? '-' : address.trim(),
            leading: Icons.location_on_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _ReadOnlyField(
            label: 'Date of Birth',
            value: dob.trim().isEmpty ? '-' : dob.trim(),
            leading: Icons.calendar_month_outlined,
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? leading;
  final int maxLines;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.leading,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          readOnly: true,
          maxLines: maxLines,
          minLines: 1,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            prefixIcon: leading == null
                ? null
                : Icon(
                    leading,
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.18),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
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
          subtitle: const Text('Get alerts for updates and reports'),
        ),
        SwitchListTile.adaptive(
          value: emailNotifications,
          onChanged: onEmailChanged,
          title: const Text('Email updates'),
          subtitle: const Text('Receive important updates by email'),
        ),
        SwitchListTile.adaptive(
          value: smsNotifications,
          onChanged: onSmsChanged,
          title: const Text('SMS notifications'),
          subtitle: const Text('Receive critical alerts via SMS'),
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
          subtitle: const Text('Allow location for better report accuracy'),
        ),
        SwitchListTile.adaptive(
          value: shareUsageData,
          onChanged: onShareUsageChanged,
          title: const Text('Share usage data'),
          subtitle: const Text('Help improve SajiloFix with analytics'),
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
          subtitle: const Text('Require fingerprint/face to open app'),
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
