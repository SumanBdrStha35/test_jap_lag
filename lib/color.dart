import 'package:flutter/material.dart';

class AppColors {
  static const Color lightGrey = Color(0xFFD6D6D6);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color grey = Colors.grey;
  static const Color blue = Colors.blue;
  static const Color green = Colors.greenAccent;
  static const Color red = Colors.redAccent;
}

class AppThemeColors {
  // Background gradient - consistent across all pages
  static const Color primaryGradientStart = Color(0xFF81A4FF);
  static const Color primaryGradientMid = Color(0xFF32FF9F);
  static const Color primaryGradientEnd = Color(0xFFFF7AE9);
  
  static List<Color> get primaryGradient => [
    primaryGradientStart,
    primaryGradientMid,
    primaryGradientEnd,
  ];
  
  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF); // white70
  
  // Glassmorphism cards
  static const Color glassPrimary = Color(0x26FFFFFF); // 15% opacity
  static const Color glassSecondary = Color(0x14FFFFFF); // 8% opacity  
  static const Color glassBorder = Color(0x4DFFFFFF); // 30% border
  static const Color glassButtonOverlay = Color(0x40FFFFFF); // 25% overlay
  
  // Shadows & others
  static const Color cardShadow = Color(0x26000000);
  static const Color iconBackground = Color(0x40FFFFFF);
}
