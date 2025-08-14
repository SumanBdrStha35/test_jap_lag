import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final MaterialColor primaryColor = Colors.lightBlue;
final MaterialAccentColor secondaryColor = Colors.lightBlueAccent;
final Color backgroundColorLight = Colors.white;
final Color backgroundColorDark = Colors.black;

final ThemeData lightTheme = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: backgroundColorLight,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: backgroundColorLight,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: primaryColor),
    bodyMedium: TextStyle(color: primaryColor),
    bodySmall: TextStyle(color: primaryColor),
    headlineMedium: TextStyle(color: primaryColor),
    headlineSmall: TextStyle(color: primaryColor),
    titleLarge: TextStyle(color: primaryColor),
    titleMedium: TextStyle(color: primaryColor),
    titleSmall: TextStyle(color: primaryColor),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: backgroundColorLight,
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: primaryColor,
    contentTextStyle: TextStyle(color: backgroundColorLight),
  ),
  appBarTheme: AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: primaryColor, //blue status bar color
      statusBarIconBrightness: Brightness.light, // For Android (dark icons)
      statusBarBrightness: Brightness.light, // For iOS (dark icons)
      systemNavigationBarColor: primaryColor, //blue navigation bar color
    ),
    backgroundColor:  primaryColor.withOpacity(0.2), //backgroundColorLight,
    iconTheme: IconThemeData(color: primaryColor),
    titleTextStyle: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold),
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: primaryColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: secondaryColor),
    ),
    labelStyle: TextStyle(color: primaryColor),
    hintStyle: TextStyle(color: secondaryColor),
  ),
  cardTheme: CardThemeData(
    color: backgroundColorLight,
    shadowColor: secondaryColor,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: secondaryColor),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryColor.shade700,
  scaffoldBackgroundColor: backgroundColorDark,
  colorScheme: ColorScheme.dark(
    primary: primaryColor.shade700,
    secondary: secondaryColor.shade700,
    surface: backgroundColorDark,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: primaryColor.shade200),
    bodyMedium: TextStyle(color: primaryColor.shade200),
    bodySmall: TextStyle(color: primaryColor.shade200),
    headlineMedium: TextStyle(color: primaryColor.shade200),
    headlineSmall: TextStyle(color: primaryColor.shade200),
    titleLarge: TextStyle(color: primaryColor.shade200),
    titleMedium: TextStyle(color: primaryColor.shade200),
    titleSmall: TextStyle(color: primaryColor.shade200),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor.shade700,
      foregroundColor: backgroundColorDark,
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: primaryColor.shade700,
    contentTextStyle: TextStyle(color: backgroundColorDark),
  ),
  appBarTheme: AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: backgroundColorDark, //dark status bar color
      statusBarIconBrightness: Brightness.light, // For Android (dark icons)
      statusBarBrightness: Brightness.dark, // For iOS (dark icons)
      systemNavigationBarColor: backgroundColorDark, //dark navigation bar color
    ),
    backgroundColor: backgroundColorDark,
    iconTheme: IconThemeData(color: primaryColor.shade200),
    titleTextStyle: TextStyle(color: primaryColor.shade200, fontSize: 20, fontWeight: FontWeight.bold),
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: primaryColor.shade700),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: secondaryColor.shade700),
    ),
    labelStyle: TextStyle(color: primaryColor.shade200),
    hintStyle: TextStyle(color: secondaryColor.shade700),
  ),
  cardTheme: CardThemeData(
    color: Colors.grey[900],
    shadowColor: secondaryColor.shade700,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: secondaryColor.shade700),
    ),
  ),
);
