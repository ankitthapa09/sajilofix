import 'package:flutter/material.dart';

ThemeData getSalijoFixAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 255, 255, 255),
    ),
    fontFamily: "Poppins",
    useMaterial3: true,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(
          fontSize: 20,
          color: Color(0xFF2449DE),
          fontWeight: FontWeight.bold,
          //fontWeight: FontWeight.w400,
        ),
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF2449DE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90)),
        elevation: 10,
      ),
    ),

    // bottomNavigationBarTheme: BottomNavigationBarThemeData(
    //   selectedItemColor: Colors.blue,
    //   unselectedItemColor: Colors.amber,
    //   showUnselectedLabels: true,
    //   type: BottomNavigationBarType.fixed,
    //   // Increase icon sizes
    //   selectedIconTheme: const IconThemeData(size: 32),
    //   unselectedIconTheme: const IconThemeData(size: 26),

    //   // Increase text sizes
    //   selectedLabelStyle: const TextStyle(
    //     fontSize: 14,
    //     fontWeight: FontWeight.w600,
    //   ),
    //   unselectedLabelStyle: const TextStyle(
    //     fontSize: 12,
    //     fontWeight: FontWeight.w500,
    //   ),

    //   elevation: 20,
    // ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent, // Glass background outside
      elevation: 0,
      type: BottomNavigationBarType.fixed,

      selectedItemColor: Color.fromARGB(255, 245, 232, 114),
      unselectedItemColor: Color.fromARGB(255, 255, 255, 255),

      selectedIconTheme: IconThemeData(size: 30),
      unselectedIconTheme: IconThemeData(size: 26),

      selectedLabelStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),

      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.black, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF155DFC), width: 2.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1557B0), width: 3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      hintStyle: const TextStyle(fontSize: 15, color: Colors.grey),
      labelStyle: const TextStyle(
        fontSize: 18,
        color: Color.fromARGB(221, 0, 0, 0),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF9F9F9), // AppBar color
      elevation: 2, // Shadow
      centerTitle: true, // Center title
      surfaceTintColor: Colors.transparent, // Remove M3 weird overlay
      iconTheme: IconThemeData(
        size: 18,
        color: Colors.black, // Back button color
      ),
      titleTextStyle: TextStyle(
        color: Colors.black, // Title color
        fontSize: 20,
        fontFamily: "Poppins",
      ),
    ),
  );
}
