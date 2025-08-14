import 'package:flutter/material.dart';
import 'package:flutter_app/pages/grammer/gram_page.dart';
import 'package:flutter_app/pages/kanji/kanji_leaves.dart';
import 'package:flutter_app/pages/voca/voca_lesson.dart';

class LessonTest extends StatefulWidget {
  const LessonTest({super.key});

  @override
  State<LessonTest> createState() => _LessonTestState();
}

class _LessonTestState extends State<LessonTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Choose Your Journey'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Master Japanese',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your learning path',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView(
                    children: [
                      _buildModernLessonCard(
                        context,
                        'Greetings',
                        'Start with essential Japanese greetings',
                        Icons.waving_hand,
                        Color(0xFFFF6B6B),
                        Color(0xFFFF8E8E),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FallingLeavesSpring()),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildModernLessonCard(
                        context,
                        'Vocabulary',
                        'Expand your word bank with daily phrases',
                        Icons.menu_book,
                        Color(0xFF4ECDC4),
                        Color(0xFF44A08D),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VocaLessonPage()),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildModernLessonCard(
                        context,
                        'Grammar',
                        'Master the structure of Japanese language',
                        Icons.psychology,
                        Color(0xFF667eea),
                        Color(0xFF764ba2),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GramPage(title: "Grammar")),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernLessonCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color startColor,
    Color endColor,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
