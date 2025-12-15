import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sajilofix/screens/bottom_screen/home_screen.dart';
import 'package:sajilofix/screens/bottom_screen/myreport_screen.dart';
import 'package:sajilofix/screens/bottom_screen/profile_screen.dart';
import 'package:sajilofix/screens/bottom_screen/report_screen.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const ReportScreen(),
    const MyreportScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: lstBottomScreen[_selectedIndex],

      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.camera_alt_rounded),
      //       label: "Report",
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.info), label: "My Reports"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      //   ],
      //   // backgroundColor: const Color.fromARGB(255, 10, 6, 242),
      //   // selectedItemColor: Colors.amber,
      //   // unselectedItemColor: Colors.white,
      //   currentIndex: _selectedIndex,
      //   onTap: (index) {
      //     setState(() {
      //       _selectedIndex = index;
      //     });
      //   },
      // ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            //height: 60,
            decoration: BoxDecoration(
              // color: const Color(0xFF1c1c85).withOpacity(0.8),
              color: Colors.blueAccent.shade400,
              border: Border(
                top: BorderSide(
                  color: const Color.fromARGB(255, 4, 23, 237).withOpacity(0.3),
                  width: 2.2,
                ),
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,

              // selectedItemColor: Colors.blue,
              // unselectedItemColor: Colors.white70,
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
