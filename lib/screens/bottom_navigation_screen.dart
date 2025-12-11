import 'package:flutter/material.dart';
import 'package:sajilofix/screens/bottom_screen/home_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    // const ReportScreen(),
    // const MyReportsScreen(),
    // const ProfileScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
