import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/main_page.dart';
import 'package:flutter_app/pages/login_page.dart';
import 'package:flutter_app/pages/onboarding_page_updated.dart';
import 'package:flutter_app/theme.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Error handling wrapper
  await runZonedGuarded(
    () async {
      await _initializeApp();
    },
    (error, stack) {
      debugPrint('App initialization error: $error');
      debugPrint('Stack trace: $stack');
    },
  );
}

Future<void> _initializeApp() async {
  try {
    // Initialize Hive with error handling
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox('vocaLessonProgress'),
      Hive.openBox('vocaQuizProgress'),
      Hive.openBox('gramQuizProgress'),
      Hive.openBox('flashCardProgress'),
    ]);

    // System UI configuration
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.blue.shade700,
        systemNavigationBarColor: Colors.blue.shade700,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Lock orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Load preferences
    final prefs = await SharedPreferences.getInstance();
    
    // Performance optimization: reduce startup delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    FlutterNativeSplash.remove();
    
    runApp(MyApp(
      isLoggedIn: prefs.getBool('isLoggedIn') ?? false,
      userId: prefs.getString('userId') ?? '',
      seenOnboarding: prefs.getBool('seenOnboarding') ?? false,
      isDarkMode: prefs.getBool('isDarkMode') ?? false,
    ));
  } catch (e) {
    debugPrint('Initialization failed: $e');
    FlutterNativeSplash.remove();
    runApp(ErrorApp(error: e.toString()));
  }
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late bool _isDarkMode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isDarkMode = widget.isDarkMode;
    _initializeTheme();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _loadThemePreference();
  }

  Future<void> _initializeTheme() async {
    await _loadThemePreference();
    setState(() => _isLoading = false);
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getBool('isDarkMode') ?? widget.isDarkMode;
      
      if (mounted) {
        setState(() => _isDarkMode = savedTheme);
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> _toggleTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newTheme = !_isDarkMode;
      
      await prefs.setBool('isDarkMode', newTheme);
      
      if (mounted) {
        setState(() => _isDarkMode = newTheme);
      }
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Japanese Learning App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Builder(
        builder: (context) {
          if (!widget.seenOnboarding) {
            return const OnboardingPageUpd();
          } else if (!widget.isLoggedIn) {
            return const LoginPage();
          } else {
            return MainPage(userID: widget.userId);
          }
        },
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'App Initialization Failed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Restart app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
