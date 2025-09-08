import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/hira_kata_page.dart';
import 'package:flutter_app/pages/kanji/kanji_steps.dart';
import 'package:flutter_app/pages/lesson_test.dart';
import 'package:flutter_app/pages/setting.dart';
import 'package:flutter_app/pages/test_page.dart';

class MainPage extends StatelessWidget {
  final String userID;
  
  const MainPage({super.key, required this.userID});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Page',
      debugShowCheckedModeBanner: false,
      home: MainPageWidget(userID: userID),
    );
  }
}

class MainPageWidget extends StatefulWidget {
  final String userID;
  
  const MainPageWidget({super.key, required this.userID});

  @override
  State<MainPageWidget> createState() => _MainPageWidgetState();
}

class _MainPageWidgetState extends State<MainPageWidget> {
  final PageController controller = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // HomePage(userID: widget.userID),
          HiraKataApp(),
          KanjiSteps(title: 'Kanji'),
          // TreeWithFallingLeaves(),
          LessonTest(),
          TestPage(title: "Test Page"),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomBarBubble(
        selectedIndex: _currentIndex,
        color: Color(0xFFF48FB1),
        backgroundColor: Colors.white,
        onSelect: (index) {
          setState(() {
            _currentIndex = index;
          });
          controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: [
          BottomBarItem(
            iconData: Icons.home,
            label: 'Hira Kata',
          ),
          BottomBarItem(
            iconData: Icons.menu_book,
            label: 'Kanji',
          ),
          BottomBarItem(
            iconData: Icons.pages,
            label: 'Lesson',
          ),
          BottomBarItem(
            iconData: Icons.show_chart,
            label: 'Test',
          ),
          BottomBarItem(
            iconData: Icons.settings,
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}
