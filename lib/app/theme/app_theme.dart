import 'package:flutter/material.dart';
import 'package:sajilofix/core/theme/gradient_outline_input_border.dart';

ThemeData getSalijoFixAppTheme() {
  const brandBlue = Color(0xFF2449DE);
  const brandIndigo = Color(0xFF3533cd);
  const brandInk = Color(0xFF041027);
  const brandGradient = LinearGradient(
    colors: [Color(0xFF041027), Color(0xFF3533cd)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
      // Keep the field readable; premium look comes from gradient border.
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      border: const GradientOutlineInputBorder(
        gradient: brandGradient,
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(width: 1.6),
      ),
      enabledBorder: GradientOutlineInputBorder(
        gradient: LinearGradient(
          colors: [Color(0xFF041027), Color(0xFF3533cd)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          width: 1.8,
          color: brandIndigo.withValues(alpha: 0.25),
        ),
      ),
      focusedBorder: const GradientOutlineInputBorder(
        gradient: LinearGradient(
          colors: [Color(0xFF3533cd), Color(0xFF041027)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(width: 2.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return brandIndigo;
        return brandInk;
      }),
      suffixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return brandIndigo;
        return brandInk;
      }),
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
