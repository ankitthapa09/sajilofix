import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/core/services/storage/user_session_service.dart';
import 'package:sajilofix/features/auth/domain/entities/auth_user.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/dashboard/authority/presentation/pages/authority_issues_page.dart';
import 'package:sajilofix/features/dashboard/authority/presentation/pages/authority_overview_page.dart';
import 'package:sajilofix/features/dashboard/authority/presentation/pages/authority_profile_page.dart';

class AuthorityDashboard extends ConsumerStatefulWidget {
  final int initialIndex;

  const AuthorityDashboard({super.key, this.initialIndex = 0});

  @override
  ConsumerState<AuthorityDashboard> createState() => _AuthorityDashboardState();
}

class _AuthorityDashboardState extends ConsumerState<AuthorityDashboard> {
  late int _selectedIndex;
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 2);
  }

  final List<Widget> _tabs = const [
    AuthorityOverviewScreen(),
    AuthorityIssuesScreen(),
    AuthorityProfileScreen(),
  ];

  void _handleRoleRedirect(AuthUser? user) {
    if (!mounted || _redirected) return;
    final hasSession = UserSessionService.isLoggedIn;
    if (user == null) {
      if (hasSession) return;
      _redirected = true;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
      return;
    }

    if (user.roleIndex == 1) {
      _redirected = true;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.adminDashboard,
        (route) => false,
      );
      return;
    }

    if (user.roleIndex != 2) {
      _redirected = true;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    return currentUserAsync.when(
      data: (user) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleRoleRedirect(user);
        });
        return _buildDashboard();
      },
      loading: _buildDashboard,
      error: (_, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleRoleRedirect(null);
        });
        return _buildDashboard();
      },
    );
  }

  Widget _buildDashboard() {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF041027), Color(0xFF3533CD)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  label: 'Overview',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_rounded),
                  label: 'Issues',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
