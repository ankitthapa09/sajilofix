import 'package:flutter/material.dart';
import 'package:sajilofix/features/dashboard/presentation/pages/home_page.dart';
import 'package:sajilofix/features/dashboard/presentation/pages/myreport_page.dart';
import 'package:sajilofix/features/dashboard/presentation/pages/profile_page.dart';
import 'package:sajilofix/features/report/presentation/pages/report_step1.dart';
//import 'package:sajilofix/features/report/presentation/pages/report_screen.dart';

class CitizenDashboard extends StatefulWidget {
  final int initialIndex;

  const CitizenDashboard({super.key, this.initialIndex = 0});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  late int _selectedIndex;

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
  @override
  Widget build(BuildContext context) {
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
}
