import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_app/pages/flash/flash_card_page.dart';
import 'package:flutter_app/pages/grammer/gram_page.dart';
import 'package:flutter_app/pages/voca/voca_quize_list.dart';

class TestPage extends StatefulWidget {
  final String title;
  
  const TestPage({super.key, required this.title});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ).animate().scale(duration: 400.ms).fadeIn(duration: 300.ms),
                        const SizedBox(width: 8),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose your learning adventure',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildGlassCard(
                      icon: Icons.quiz_outlined,
                      title: 'Vocabulary Quiz',
                      subtitle: 'Test your word knowledge with interactive quizzes',
                      gradientColors: [Colors.green, Colors.teal],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VocaQuizeListPage(),
                          ),
                        );
                      },
                    ).animate().scale(duration: 600.ms).fadeIn(delay: 200.ms),
                    const SizedBox(height: 20),
                    _buildGlassCard(
                      icon: Icons.menu_book_outlined,
                      title: 'Grammar Quiz',
                      subtitle: 'Master Japanese grammar with structured practice',
                      gradientColors: [Colors.blue, Colors.indigo],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GramPage(title: "Grammar", selectedIndex: 1,),
                          ),
                        );
                      },
                    ).animate().scale(duration: 600.ms).fadeIn(delay: 400.ms),
                    const SizedBox(height: 20),
                    _buildGlassCard(
                      icon: Icons.flash_on_outlined,
                      title: 'Flash Cards',
                      subtitle: 'Practice with interactive flashcards for quick recall',
                      gradientColors: [Colors.orange, Colors.red],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlashCardPage(title: 'Flashcard'),
                          ),
                        );
                      },
                    ).animate().scale(duration: 600.ms).fadeIn(delay: 600.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ).animate().scale(duration: 400.ms).shimmer(duration: 800.ms),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ).animate().scale(duration: 300.ms).rotate(duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .scale(duration: 400.ms, curve: Curves.easeOutBack)
      .fadeIn(duration: 300.ms)
      .shimmer(duration: 1000.ms)
      .animate(onPlay: (controller) => controller.repeat())
      .shimmer(duration: 2000.ms, delay: 1000.ms);
  }
}
