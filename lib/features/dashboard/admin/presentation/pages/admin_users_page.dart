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

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  String _roleFilter = '';
  String _statusFilter = '';

  AnimationController? _animController;
  Animation<double> _fadeAnim = const AlwaysStoppedAnimation(1.0);

  static const _blue = Color(0xFF2563EB);
  static const _indigo = Color(0xFF4F46E5);
  static const _green = Color(0xFF059669);
  static const _red = Color(0xFFDC2626);
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
    _scrollController.addListener(_handleScroll);
    _searchController.addListener(_handleSearch);
    Future.microtask(
      () => ref.read(adminUsersControllerProvider.notifier).load(),
    );
  }

  @override
  void dispose() {
    _animController?.dispose();
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

  void _applyFilters() {
    ref
        .read(adminUsersControllerProvider.notifier)
        .load(
          search: _searchController.text,
          role: _roleFilter,
          status: _statusFilter,
        );
  }

  Future<void> _openCreate(String role) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminUserFormPage(role: role)),
    );
    if (created == true)
      await ref.read(adminUsersControllerProvider.notifier).refresh();
  }

  Future<void> _openEdit(AdminUserRow user) async {
    if (user.role == 'admin') return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminUserFormPage(role: user.role, user: user),
      ),
    );
    if (updated == true)
      await ref.read(adminUsersControllerProvider.notifier).refresh();
  }

  Future<void> _confirmDelete(AdminUserRow user) async {
    if (user.role == 'admin') return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _red, size: 22),
            SizedBox(width: 8),
            Text(
              'Delete User',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${user.fullName}? This action cannot be undone.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(adminUsersControllerProvider);
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0D14)
          : const Color(0xFFF0F2F8),
      floatingActionButton: _CreateFAB(
        onCreateAuthority: () => _openCreate('authority'),
        onCreateCitizen: () => _openCreate('citizen'),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Gradient header ──────────────────────
            SliverToBoxAdapter(
              child: _AdminPageHeader(
                isDark: isDark,
                onRefresh: () =>
                    ref.read(adminUsersControllerProvider.notifier).refresh(),
              ),
            ),

            // ── Stats row ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _StatsRow(users: state.users, isDark: isDark),
              ),
            ),

            // ── Error ────────────────────────────────────
            if ((state.error ?? '').trim().isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: _red,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.error ?? '',
                            style: const TextStyle(color: _red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Search ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _SearchBar(
                  controller: _searchController,
                  isDark: isDark,
                ),
              ),
            ),

            // ── Role filters ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _RoleChip(
                        label: 'All',
                        icon: Icons.people_outline_rounded,
                        color: _blue,
                        selected: _roleFilter.isEmpty,
                        onTap: () {
                          setState(() => _roleFilter = '');
                          _applyFilters();
                        },
                      ),
                      _RoleChip(
                        label: 'Citizens',
                        icon: Icons.person_outline_rounded,
                        color: _blue,
                        selected: _roleFilter == 'citizen',
                        onTap: () {
                          setState(() => _roleFilter = 'citizen');
                          _applyFilters();
                        },
                      ),
                      _RoleChip(
                        label: 'Authorities',
                        icon: Icons.shield_outlined,
                        color: _indigo,
                        selected: _roleFilter == 'authority',
                        onTap: () {
                          setState(() => _roleFilter = 'authority');
                          _applyFilters();
                        },
                      ),
                      _RoleChip(
                        label: 'Admins',
                        icon: Icons.admin_panel_settings_outlined,
                        color: _amber,
                        selected: _roleFilter == 'admin',
                        onTap: () {
                          setState(() => _roleFilter = 'admin');
                          _applyFilters();
                        },
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
            ),

            // ── Status filters ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _StatusChip(
                        label: 'All Status',
                        color: _blue,
                        selected: _statusFilter.isEmpty,
                        onTap: () {
                          setState(() => _statusFilter = '');
                          _applyFilters();
                        },
                      ),
                      _StatusChip(
                        label: 'Active',
                        color: _green,
                        selected: _statusFilter == 'active',
                        onTap: () {
                          setState(() => _statusFilter = 'active');
                          _applyFilters();
                        },
                      ),
                      _StatusChip(
                        label: 'Suspended',
                        color: _red,
                        selected: _statusFilter == 'suspended',
                        onTap: () {
                          setState(() => _statusFilter = 'suspended');
                          _applyFilters();
                        },
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
            ),

            // ── Count label ──────────────────────────────
            if (!state.isLoading && state.users.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Text(
                    '${state.users.length} user${state.users.length == 1 ? '' : 's'}${state.hasMore ? ' · scroll for more' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),

            // ── List ─────────────────────────────────────
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.users.isEmpty)
              SliverFillRemaining(child: _EmptyState(isDark: isDark))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final user = state.users[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _UserCard(
                        user: user,
                        isDark: isDark,
                        onEdit: () => _openEdit(user),
                        onDelete: () => _confirmDelete(user),
                      ),
                    );
                  }, childCount: state.users.length),
                ),
              ),

            // ── Load more ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: state.isLoadingMore
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : state.hasMore
                    ? GestureDetector(
                        onTap: () => ref
                            .read(adminUsersControllerProvider.notifier)
                            .loadMore(),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: _blue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _blue.withValues(alpha: 0.2),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.expand_more_rounded,
                                color: _blue,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Load more',
                                style: TextStyle(
                                  color: _blue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
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

// ─────────────────────────────────────────────────────────────
// Admin Page Header
// ─────────────────────────────────────────────────────────────
class _AdminPageHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRefresh;

  const _AdminPageHeader({required this.isDark, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
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
              Row(
                children: [
                  Hero(
                    tag: HeroTags.appLogo,
                    child: Image.asset(
                      'assets/images/sajilofix_logo.png',
                      height: 36,
                    ),
                  ),
                  const Spacer(),
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.admin_panel_settings_outlined,
                          color: Colors.white70,
                          size: 13,
                        ),
                        SizedBox(width: 5),
                        Text(
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
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onRefresh,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white70,
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'User Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage citizens and authorities',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Admin Page Header
// ─────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────
// Icon Button helper
// ─────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2330) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE5E7EB),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white60 : const Color(0xFF374151),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final List<AdminUserRow> users;
  final bool isDark;

  const _StatsRow({required this.users, required this.isDark});

  static const _blue = Color(0xFF2563EB);
  static const _green = Color(0xFF059669);
  static const _indigo = Color(0xFF4F46E5);
  static const _red = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final total = users.length;
    final citizens = users.where((u) => u.role == 'citizen').length;
    final authorities = users.where((u) => u.role == 'authority').length;
    final suspended = users.where((u) => u.status == 'suspended').length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '$total',
            label: 'Total',
            icon: Icons.people_outline_rounded,
            color: _blue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '$citizens',
            label: 'Citizens',
            icon: Icons.person_outline_rounded,
            color: _green,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '$authorities',
            label: 'Authorities',
            icon: Icons.shield_outlined,
            color: _indigo,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '$suspended',
            label: 'Suspended',
            icon: Icons.block_outlined,
            color: _red,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B27) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const _SearchBar({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B27) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF111827),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search by name or email…',
          hintStyle: TextStyle(
            color: isDark ? Colors.white24 : Colors.grey.shade400,
            fontSize: 13,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? Colors.white38 : Colors.grey.shade400,
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Filter Chips
// ─────────────────────────────────────────────────────────────
class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color
              : (isDark ? const Color(0xFF161B27) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? color
                : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE5E7EB)),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white54 : const Color(0xFF6B7280)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white54 : const Color(0xFF374151)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark ? const Color(0xFF161B27) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.6)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE5E7EB)),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? color
                    : (isDark ? Colors.white24 : const Color(0xFFD1D5DB)),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected
                    ? color
                    : (isDark ? Colors.white54 : const Color(0xFF6B7280)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// User Card  (bigger, richer layout)
// ─────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final AdminUserRow user;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  static const _blue = Color(0xFF2563EB);
  static const _indigo = Color(0xFF4F46E5);
  static const _amber = Color(0xFFD97706);
  static const _green = Color(0xFF059669);
  static const _red = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleAccent(user.role);
    final roleLabel = _roleLabel(user.role);
    final roleIcon = _roleIcon(user.role);
    final isActive = user.status != 'suspended';
    final statusColor = isActive ? _green : _red;
    final photoUrl = _buildPhotoUrl(ApiEndpoints.baseUrl, user.profilePhoto);
    final isAdmin = user.role == 'admin';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B27) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: roleColor.withValues(alpha: 0.15)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: roleColor.withValues(alpha: 0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        children: [
          // ── Coloured left-stripe layout ──────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [roleColor, roleColor.withValues(alpha: 0.3)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                ),

                // Card body
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 14, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Row 1: Avatar + name + menu ───
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            _Avatar(
                              name: user.fullName,
                              imageUrl: photoUrl,
                              roleColor: roleColor,
                              isDark: isDark,
                              size: 66,
                            ),
                            const SizedBox(width: 14),

                            // Name + email + dept
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white38
                                          : const Color(0xFF6B7280),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if ((user.department ?? '')
                                      .trim()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.business_center_outlined,
                                          size: 12,
                                          color: isDark
                                              ? Colors.white30
                                              : Colors.grey.shade400,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            user.department!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? Colors.white30
                                                  : Colors.grey.shade500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Popup menu or protected badge
                            if (!isAdmin)
                              PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'edit') onEdit();
                                  if (v == 'delete') onDelete();
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                offset: const Offset(0, 8),
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                          color: _blue,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Edit User',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          size: 16,
                                          color: _red,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: _red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Icon(
                                    Icons.more_vert_rounded,
                                    size: 17,
                                    color: isDark
                                        ? Colors.white54
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _amber.withValues(
                                    alpha: isDark ? 0.18 : 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _amber.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Text(
                                  'Protected',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _amber,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // ── Divider ──────────────────────
                        Divider(
                          height: 1,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : const Color(0xFFF1F5F9),
                        ),

                        const SizedBox(height: 12),

                        // ── Row 2: location + role + status ──
                        Row(
                          children: [
                            // Location
                            if ((user.municipality ?? '')
                                .trim()
                                .isNotEmpty) ...[
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: isDark
                                    ? Colors.white30
                                    : Colors.grey.shade400,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  '${(user.wardNumber ?? '').isNotEmpty ? 'Ward ${user.wardNumber}, ' : ''}${user.municipality}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white30
                                        : Colors.grey.shade500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ] else
                              const Spacer(),

                            const SizedBox(width: 8),

                            // Role pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: roleColor.withValues(
                                  alpha: isDark ? 0.18 : 0.08,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: roleColor.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(roleIcon, size: 11, color: roleColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    roleLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: roleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 6),

                            // Status pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(
                                  alpha: isDark ? 0.18 : 0.08,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: statusColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isActive ? 'Active' : 'Suspended',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _roleAccent(String role) {
    switch (role) {
      case 'authority':
        return _indigo;
      case 'admin':
        return _amber;
      default:
        return _blue;
    }
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

  IconData _roleIcon(String role) {
    switch (role) {
      case 'authority':
        return Icons.shield_outlined;
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.person_outline_rounded;
    }
  }

  String? _buildPhotoUrl(String baseUrl, String? profilePhoto) {
    final rel = (profilePhoto ?? '').trim();
    if (rel.isEmpty) return null;
    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanRel = rel.replaceAll(RegExp(r'^/+'), '');
    if (cleanRel.startsWith('uploads/')) return '$cleanBase/$cleanRel';
    return '$cleanBase/uploads/$cleanRel';
  }
}

// ─────────────────────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final Color roleColor;
  final bool isDark;
  final double size;

  const _Avatar({
    required this.name,
    required this.imageUrl,
    required this.roleColor,
    required this.isDark,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '?'
        : name
              .trim()
              .split(' ')
              .take(2)
              .map((w) => w.isNotEmpty ? w[0] : '')
              .join()
              .toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: roleColor.withValues(alpha: 0.12),
        border: Border.all(color: roleColor.withValues(alpha: 0.3), width: 2),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: roleColor.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: ClipOval(
        child: (imageUrl ?? '').isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialsWidget(initials),
              )
            : _initialsWidget(initials),
      ),
    );
  }

  Widget _initialsWidget(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: roleColor,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.3,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.people_outline_rounded,
              size: 36,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search or filters.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Create FAB
// ─────────────────────────────────────────────────────────────
class _CreateFAB extends StatelessWidget {
  final VoidCallback onCreateAuthority;
  final VoidCallback onCreateCitizen;

  const _CreateFAB({
    required this.onCreateAuthority,
    required this.onCreateCitizen,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final action = await showModalBottomSheet<String>(
          context: context,
          showDragHandle: true,
          backgroundColor: isDark ? const Color(0xFF161B27) : Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 0, 0, 16),
                    child: Text(
                      'Create New User',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  _SheetOption(
                    icon: Icons.shield_outlined,
                    iconColor: const Color(0xFF4F46E5),
                    title: 'Create Authority',
                    subtitle: 'Municipal officer or department head',
                    onTap: () => Navigator.pop(ctx, 'authority'),
                  ),
                  const SizedBox(height: 10),
                  _SheetOption(
                    icon: Icons.person_outline_rounded,
                    iconColor: const Color(0xFF2563EB),
                    title: 'Create Citizen',
                    subtitle: 'Registered community member',
                    onTap: () => Navigator.pop(ctx, 'citizen'),
                  ),
                ],
              ),
            ),
          ),
        );
        if (action == 'authority')
          onCreateAuthority();
        else if (action == 'citizen')
          onCreateCitizen();
      },
      backgroundColor: const Color(0xFF2563EB),
      foregroundColor: Colors.white,
      elevation: 6,
      icon: const Icon(Icons.person_add_outlined, size: 20),
      label: const Text(
        'Create User',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: isDark ? Colors.white24 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
