import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/core/constants/hero_tags.dart';
import 'package:sajilofix/features/dashboard/admin/domain/entities/admin_user_row.dart';
import 'package:sajilofix/features/dashboard/admin/presentation/pages/admin_user_form_page.dart';
import 'package:sajilofix/features/dashboard/admin/presentation/providers/admin_users_providers.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  String _roleFilter = '';
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _searchController.addListener(_handleSearch);
    Future.microtask(
      () => ref.read(adminUsersControllerProvider.notifier).load(),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref
          .read(adminUsersControllerProvider.notifier)
          .load(
            search: _searchController.text,
            role: _roleFilter,
            status: _statusFilter,
          );
    });
  }

  void _handleScroll() {
    if (_scrollController.position.pixels + 120 >=
        _scrollController.position.maxScrollExtent) {
      ref.read(adminUsersControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _openCreate(String role) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminUserFormPage(role: role)),
    );
    if (created == true) {
      await ref.read(adminUsersControllerProvider.notifier).refresh();
    }
  }

  Future<void> _openEdit(AdminUserRow user) async {
    if (user.role == 'admin') return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminUserFormPage(role: user.role, user: user),
      ),
    );
    if (updated == true) {
      await ref.read(adminUsersControllerProvider.notifier).refresh();
    }
  }

  Future<void> _confirmDelete(AdminUserRow user) async {
    if (user.role == 'admin') return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete user?'),
        content: Text('Delete ${user.fullName}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(adminUsersControllerProvider.notifier)
            .deleteUser(id: user.id, role: user.role);
        if (!context.mounted) return;
        showMySnackBar(
          context: context,
          message: 'User deleted.',
          icon: Icons.check_circle_outline,
        );
      } catch (e) {
        if (!context.mounted) return;
        showMySnackBar(
          context: context,
          message: e.toString(),
          isError: true,
          icon: Icons.error_outline,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(adminUsersControllerProvider);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1117)
          : const Color(0xFFF4F6FB),
      floatingActionButton: _CreateButton(
        onCreateAuthority: () => _openCreate('authority'),
        onCreateCitizen: () => _openCreate('citizen'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
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
                      onPressed: () {
                        ref
                            .read(adminUsersControllerProvider.notifier)
                            .refresh();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Users',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage citizens and authorities in one place.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if ((state.error ?? '').trim().isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.error ?? 'Failed to load users.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or email',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E2330) : Colors.white,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _FilterChip(
                      label: 'All Roles',
                      selected: _roleFilter.isEmpty,
                      onTap: () {
                        setState(() => _roleFilter = '');
                        ref
                            .read(adminUsersControllerProvider.notifier)
                            .load(
                              search: _searchController.text,
                              role: _roleFilter,
                              status: _statusFilter,
                            );
                      },
                    ),
                    _FilterChip(
                      label: 'Citizens',
                      selected: _roleFilter == 'citizen',
                      onTap: () {
                        setState(() => _roleFilter = 'citizen');
                        ref
                            .read(adminUsersControllerProvider.notifier)
                            .load(
                              search: _searchController.text,
                              role: _roleFilter,
                              status: _statusFilter,
                            );
                      },
                    ),
                    _FilterChip(
                      label: 'Authorities',
                      selected: _roleFilter == 'authority',
                      onTap: () {
                        setState(() => _roleFilter = 'authority');
                        ref
                            .read(adminUsersControllerProvider.notifier)
                            .load(
                              search: _searchController.text,
                              role: _roleFilter,
                              status: _statusFilter,
                            );
                      },
                    ),
                    _FilterChip(
                      label: 'Admins',
                      selected: _roleFilter == 'admin',
                      onTap: () {
                        setState(() => _roleFilter = 'admin');
                        ref
                            .read(adminUsersControllerProvider.notifier)
                            .load(
                              search: _searchController.text,
                              role: _roleFilter,
                              status: _statusFilter,
                            );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _FilterChip(
                      label: 'All Status',
                      selected: _statusFilter.isEmpty,
                      onTap: () {
                        setState(() => _statusFilter = '');
                        ref
                            .read(adminUsersControllerProvider.notifier)
                            .load(
                              search: _searchController.text,
                              role: _roleFilter,
                              status: _statusFilter,
                            );
                      },
                    ),
                    _FilterChip(
                      label: 'Active',
                      selected: _statusFilter == 'active',
                      onTap: () {
                        setState(() => _statusFilter = 'active');
                        ref
                            .read(adminUsersControllerProvider.notifier)
                            .load(
                              search: _searchController.text,
                              role: _roleFilter,
                              status: _statusFilter,
                            );
                      },
                    ),
                    _FilterChip(
                      label: 'Suspended',
                      selected: _statusFilter == 'suspended',
                      onTap: () {
                        setState(() => _statusFilter = 'suspended');
                        ref
                            .read(adminUsersControllerProvider.notifier)
                            .load(
                              search: _searchController.text,
                              role: _roleFilter,
                              status: _statusFilter,
                            );
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.users.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No users found',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final user = state.users[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _UserCard(
                        user: user,
                        onEdit: () => _openEdit(user),
                        onDelete: () => _confirmDelete(user),
                      ),
                    );
                  }, childCount: state.users.length),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: state.isLoadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : state.hasMore
                    ? OutlinedButton.icon(
                        onPressed: () => ref
                            .read(adminUsersControllerProvider.notifier)
                            .loadMore(),
                        icon: const Icon(Icons.expand_more_rounded),
                        label: const Text('Load more'),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AdminUserRow user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final roleLabel = _roleLabel(user.role);
    final statusColor = user.status == 'suspended'
        ? const Color(0xFFEF4444)
        : const Color(0xFF10B981);
    final photoUrl = _buildProfilePhotoUrl(
      ApiEndpoints.baseUrl,
      user.profilePhoto,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2330) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        children: [
          _ProfileAvatar(
            label: roleLabel.substring(0, 1),
            imageUrl: photoUrl,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if ((user.department ?? '').trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      user.department ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Pill(label: roleLabel, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              _Pill(
                label: user.status == 'suspended' ? 'Suspended' : 'Active',
                color: statusColor,
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                enabled: user.role != 'admin',
                child: const Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                enabled: user.role != 'admin',
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'authority':
        return 'Authority';
      case 'admin':
        return 'Admin';
      default:
        return 'Citizen';
    }
  }

  String? _buildProfilePhotoUrl(String baseUrl, String? profilePhoto) {
    final rel = (profilePhoto ?? '').trim();
    if (rel.isEmpty) return null;
    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanRel = rel.replaceAll(RegExp(r'^/+'), '');
    if (cleanRel.startsWith('uploads/')) return '$cleanBase/$cleanRel';
    return '$cleanBase/uploads/$cleanRel';
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final bool isDark;

  const _ProfileAvatar({
    required this.label,
    required this.imageUrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = (imageUrl ?? '').trim().isNotEmpty;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary.withValues(alpha: 0.15),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarFallback(theme),
              )
            : _avatarFallback(theme),
      ),
    );
  }

  Widget _avatarFallback(ThemeData theme) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.14)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.4)
                : theme.dividerColor.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onCreateAuthority;
  final VoidCallback onCreateCitizen;

  const _CreateButton({
    required this.onCreateAuthority,
    required this.onCreateCitizen,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final action = await showModalBottomSheet<String>(
          context: context,
          showDragHandle: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_add_alt_1_outlined),
                    title: const Text('Create Authority'),
                    onTap: () => Navigator.pop(context, 'authority'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Create Citizen'),
                    onTap: () => Navigator.pop(context, 'citizen'),
                  ),
                ],
              ),
            ),
          ),
        );

        if (action == 'authority') {
          onCreateAuthority();
        } else if (action == 'citizen') {
          onCreateCitizen();
        }
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('Create'),
    );
  }
}
