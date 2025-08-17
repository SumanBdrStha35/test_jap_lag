import 'package:flutter/material.dart';
import 'package:flutter_app/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/onboarding1.jpg',
      'text': 'Welcome to our app! Discover new features.',
    },
    {
      'image': 'assets/onboarding2.jpg',
      'text': 'Stay connected with your friends and family.',
    },
    {
      'image': 'assets/onboarding3.jpg',
      'text': 'Get notifications about important updates.',
    },
    {
      'image': 'assets/onboarding4.jpg',
      'text': 'Customize your profile and settings easily.',
    },
    {
      'image': 'assets/onboarding5.jpg',
      'text': 'Start your journey with us today!',
    },
  ];

  void _onNext() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page, set seenOnboarding to true and navigate to login page
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Widget _buildPageContent(Map<String, String> page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          page['image']!,
          width: 300,
          height: 300,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            page['text']!,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 6),
          width: _currentPage == index ? 24 : 12,
          height: 12,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.red : Colors.grey,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                return _buildPageContent(_pages[index]);
              },
            ),
          ),
          _buildPageIndicator(),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text(
                _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
              ),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
