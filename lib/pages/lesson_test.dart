import 'package:flutter/material.dart';
import 'package:flutter_app/pages/grammer/gram_page.dart';
import 'package:flutter_app/pages/others/greeting.dart';
import 'package:flutter_app/pages/voca/voca_lesson_updated.dart';

class LessonTest extends StatelessWidget {
  const LessonTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Choose Your',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const Text(
                      'Learning Path',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Master Japanese with curated lessons',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF2D3436).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content - Grid Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85, // Adjusted ratio for better fit
                  children: [
                    _buildLessonCard(
                      context,
                      'Vocabulary',
                      'Daily phrases & common expressions',
                      Icons.menu_book,
                      const Color(0xFF00BCD4),
                      const VocaLessonPageUpdate(),
                    ),
                    _buildLessonCard(
                      context,
                      'Grammar',
                      'Master Japanese sentence structure',
                      Icons.psychology,
                      const Color(0xFF8BC34A),
                      const GramPage(title: "Grammar", selectedIndex: 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              // Subheader for Small Lessons
              Text(
                "Small lessons parts!",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85, // Adjusted ratio for better fit
                  children: [
                    _buildLessonCard(
                      context,
                      'Greetings',
                      'Learn common Japanese greetings',
                      Icons.handshake_outlined,
                      const Color(0xFFFF6B6B),
                      const AppendicesPage(
                        pTitle: 'Greetings',
                        fileName: 'appendices_aisatsu',
                      ),
                    ),
                    _buildLessonCard(
                      context,
                      'Counter Suffixes',
                      'Learn Japanese counting',
                      Icons.countertops_outlined,
                      const Color(0xFFFF9800),
                      const AppendicesPage(
                        pTitle: 'Counting',
                        fileName: 'appendices_counter',
                      ),
                    ),
                    _buildLessonCard(
                      context,
                      'Numbers',
                      'Learn Japanese numbers',
                      Icons.numbers_outlined,
                      const Color(0xFFE91E63),
                      const AppendicesPage(
                        pTitle: 'Numbers',
                        fileName: 'appendices_number',
                      ),
                    ),
                    _buildLessonCard(
                      context,
                      'Body',
                      'Person body parts.',
                      Icons.person_outlined,
                      const Color(0xFF9C27B0),
                      const AppendicesPage(
                        pTitle: 'Body',
                        fileName: 'appendices_body',
                      ),
                    ),
                    _buildLessonCard(
                      context,
                      'Color',
                      'Color names.',
                      Icons.color_lens_outlined,
                      const Color(0xFF3F51B5),
                      const AppendicesPage(
                        pTitle: 'Color',
                        fileName: 'appendices_color',
                      ),
                    ),
                    _buildLessonCard(
                      context,
                      'Family',
                      'Name of family members.',
                      Icons.family_restroom_outlined,
                      const Color(0xFF009688),
                      const AppendicesPage(
                        pTitle: 'Family',
                        fileName: 'appendices_family',
                      ),
                    ),
                    _buildLessonCard(
                      context,
                      'Time',
                      'Time of day, seasons, and days of the week.',
                      Icons.timer_outlined,
                      const Color(0xFF795548),
                      const AppendicesPage(
                        pTitle: 'Time',
                        fileName: 'appendices_time',
                      ),
                    ),
                    //verb group I II III
                    _buildLessonCard(
                      context,
                      'Verb',
                      'Verb group I, II, III.',
                      Icons.groups_3_outlined,
                      const Color(0xFF607D8B),
                      const AppendicesPage(
                        pTitle: 'Verb',
                        fileName: 'appendices_verbs',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget page,
  ) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Added to prevent overflow
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF2D3436).withOpacity(0.7),
                ),
                maxLines: 2, // Added to prevent overflow
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
