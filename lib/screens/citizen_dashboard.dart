import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sajilofix/screens/bottom_screen/home_screen.dart';
import 'package:sajilofix/screens/bottom_screen/myreport_screen.dart';
import 'package:sajilofix/screens/bottom_screen/profile_screen.dart';
import 'package:sajilofix/screens/bottom_screen/report/report_step1.dart';
//import 'package:sajilofix/screens/bottom_screen/report_screen.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  int _selectedIndex = 0;

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
