import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/main_page.dart';
import 'package:flutter_app/pages/onboarding_page.dart';
import 'package:flutter_app/pages/login_page.dart';
import 'package:flutter_app/theme.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keeps splash until you remove it manually
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  await Hive.openBox('vocaLessonProgress');
  await Hive.openBox('vocaQuizProgress');
  await Hive.openBox('gramQuizProgress');
  await Hive.openBox('flashCardProgress');

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.blue, // Set your desired status bar color here
    systemNavigationBarColor: Colors.blue, // Set your desired navigation bar color here
    systemNavigationBarIconBrightness: Brightness.light, // Set icon brightness
  ));

  // Load SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String userId = prefs.getString('userId') ?? '';
  bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  
  // Simulate some startup work
  await Future.delayed(Duration(seconds: 5));
  // Remove the splash screen
  FlutterNativeSplash.remove();
  
  runApp(MyApp(
    isLoggedIn: isLoggedIn, 
    userId: userId, 
    seenOnboarding: seenOnboarding,
    isDarkMode: isDarkMode,
  ));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final String userId;
  final bool seenOnboarding;
  final bool isDarkMode;

  const MyApp({
    super.key, 
    required this.isLoggedIn, 
    required this.userId, 
    required this.seenOnboarding,
    required this.isDarkMode,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: !widget.seenOnboarding
          ? const OnboardingPage()
          : (widget.isLoggedIn ? MainPage(userID: widget.userId) : const LoginPage()),
    );
  }
}
