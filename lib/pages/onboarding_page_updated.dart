import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/login_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPageUpd extends StatefulWidget {
  const OnboardingPageUpd({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPageUpd>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'image': 'assets/onboarding1.jpg',
      'title': 'Welcome to Our App',
      'subtitle':
          'Discover amazing features that will transform your experience',
      // 'gradient': [Color(0xFFFFB6E6), Color(0xFFD6B3FF)],
      // 'gradient': [Color(0xFFFFB6D9), Color(0xFFA5F2F3)],
      'gradient': [Color(0xFFFF9AD5), Color(0xFFB399FF)],
    },
    {
      'image': 'assets/onboarding2.jpg',
      'title': 'Stay Connected',
      'subtitle': 'Never miss a moment with your friends and family',
      // 'gradient': [Color(0xFFA5E6FF), Color(0xFFA0F0D0)],
      // 'gradient': [Color(0xFFFFD3A3), Color(0xFFB4E8FF)],
      'gradient': [Color(0xFF6DDBFF), Color(0xFF7FA6FF)],
    },
    {
      'image': 'assets/onboarding3.jpg',
      'title': 'Smart Notifications',
      'subtitle': 'Get timely updates about what matters most to you',
      // 'gradient': [Color(0xFFFFD1A8), Color(0xFFFFB7B7)],
      // 'gradient': [Color(0xFFD4FFC4), Color(0xFFFFC1F3)],
      'gradient': [Color(0xFFFFC87C), Color(0xFFFF9E9E)],
    },
    {
      'image': 'assets/onboarding4.jpg',
      'title': 'Personalize Your Experience',
      'subtitle': 'Customize everything to match your unique style',
      // 'gradient': [Color(0xFFE2C2FF), Color(0xFFB5D8FF)],
      // 'gradient': [Color(0xFFF0E6FF), Color(0xFFFFFFC1)],
      'gradient': [Color(0xFFA8FFC1), Color(0xFF6FDDFF)],
    },
    {
      'image': 'assets/onboarding5.jpg',
      'title': 'Ready to Start?',
      'subtitle': 'Join thousands of happy users on this amazing journey',
      // 'gradient': [Color(0xFFFFF3A8), Color(0xFFC8F7C5)],
      // 'gradient': [Color(0xFFFFF2A0), Color(0xFFD1F0FF)],
      'gradient': [Color(0xFFFFF07C), Color(0xFFA5FFA5)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onNext() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await _completeOnboarding();
    }
  }

  void _onSkip() async {
    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);

      // Add haptic feedback
      HapticFeedback.lightImpact();

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      // Fallback navigation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Widget _buildBackgroundGradient(List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
          stops: [0.0, 1.0],
        ),
      ),
    );
  }

  Widget _buildPageContent(Map<String, dynamic> page, int index) {
    return Stack(
      children: [
        _buildBackgroundGradient(page['gradient']),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 2),
                Hero(
                      tag: 'image-$index',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            page['image']!,
                            width: 280,
                            height: 280,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .slideY(begin: 0.3, end: 0, duration: 600.ms),
                SizedBox(height: 40),
                Text(
                      page['title']!,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 200.ms)
                    .slideY(begin: 0.2, end: 0, duration: 800.ms),
                SizedBox(height: 16),
                Text(
                      page['subtitle']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 400.ms)
                    .slideY(begin: 0.2, end: 0, duration: 800.ms),
                Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkipButton() {
    return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 24),
              child: TextButton(
                onPressed: _onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideX(begin: 1, end: 0, duration: 500.ms);
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
            );
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 6),
            width: _currentPage == index ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  _currentPage == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
              boxShadow:
                  _currentPage == index
                      ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms);
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
      child: Row(
        children: [
          if (_currentPage > 0) ...[
            FloatingActionButton(
              heroTag: 'back',
              onPressed: () {
                _pageController.previousPage(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
              },
              backgroundColor: Colors.white.withOpacity(0.2),
              elevation: 0,
              mini: true,
              child: Icon(Icons.arrow_back, color: Colors.white),
            ).animate().fadeIn(duration: 300.ms).scale(duration: 300.ms),
            SizedBox(width: 16),
          ],
          Expanded(
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 56),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Continue',
                      key: ValueKey(_currentPage),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 500.ms, delay: 800.ms)
              .slideY(begin: 0.5, end: 0, duration: 500.ms),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
              _animationController.animateTo(
                page / (_pages.length - 1),
                duration: Duration(milliseconds: 300),
              );
            },
            itemBuilder: (context, index) {
              return _buildPageContent(_pages[index], index);
            },
          ),
          _buildSkipButton(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildPageIndicator(), _buildActionButtons()],
            ),
          ),
        ],
      ),
    );
  }
}
