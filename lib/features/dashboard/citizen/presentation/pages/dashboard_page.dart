import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/core/services/storage/user_session_service.dart';
import 'package:sajilofix/features/auth/domain/entities/auth_user.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/pages/home_page.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/pages/myreport_page.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/pages/profile_page.dart';
import 'package:sajilofix/features/report/presentation/pages/report_step1.dart';
//import 'package:sajilofix/features/report/presentation/pages/report_screen.dart';

class CitizenDashboard extends ConsumerStatefulWidget {
  final int initialIndex;

  const CitizenDashboard({super.key, this.initialIndex = 0});

  @override
  ConsumerState<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends ConsumerState<CitizenDashboard> {
  late int _selectedIndex;
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 3);
  }

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const ReportStep1(),
    const MyreportScreen(),
    const ProfileScreen(),
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
    }
  }

  Widget _buildDashboard() {
    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF041027), Color(0xFF3533cd)],
            ),
          ),

          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt_rounded),
                  label: "Report",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_rounded),
                  label: "My Reports",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}
