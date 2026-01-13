import 'package:flutter/material.dart';

ThemeData getSalijoFixAppTheme() {
  const brandBlue = Color(0xFF2449DE);
  const brandIndigo = Color(0xFF3533cd);

  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandIndigo,
      brightness: Brightness.light,
    ).copyWith(primary: brandIndigo, secondary: brandBlue),
    fontFamily: "Poppins",
    useMaterial3: true,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: brandIndigo,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(
          fontSize: 20,
          color: brandBlue,
          fontWeight: FontWeight.bold,
          //fontWeight: FontWeight.w400,
        ),
        foregroundColor: Colors.white,
        backgroundColor: brandIndigo,
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
      elevation: 0,
      type: BottomNavigationBarType.fixed,

      selectedItemColor: Color.fromARGB(255, 255, 255, 255),
      unselectedItemColor: Color.fromARGB(255, 165, 165, 165),

      selectedIconTheme: IconThemeData(size: 32),
      unselectedIconTheme: IconThemeData(size: 28),

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
      backgroundColor: Color(0xFFF9F9F9),
      elevation: 9,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      //iconTheme: IconThemeData(size: 18, color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontFamily: "Poppins",
      ),
    ),
  );
}
