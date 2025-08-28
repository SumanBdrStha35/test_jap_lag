import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_app/pages/grammer/gama_test1.dart';
import 'package:flutter_app/pages/grammer/gram_quize.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GramPage extends StatefulWidget {
  final String title;
  final int selectedIndex;

  const GramPage({super.key, required this.title, required this.selectedIndex});

  @override
  State<GramPage> createState() => _GramPageState();
}

class _GramPageState extends State<GramPage> {
  late Box _progressBox;

  // List of grammar topics
  final List<Map<String, dynamic>> _japaneseGrammar = [
    {
      'title': 'Japanese Grammar Part 1',
      'subtitle': '~ 7 Very Basic Sentence Patterns ~',
      'progress': 0,
    },
    {
      'title': 'Japanese Grammar Part 2',
      'subtitle': '~ よね(yone) / Past Tense ~',
      'progress': 0,
    },
    {
      'title': 'Japanese Grammar Part 3',
      'subtitle': '~ How to Use Japanese Verbs ~',
      'progress': 0,
    },
    {
      'title': 'Japanese Grammar Part 4',
      'subtitle': '~ How to Use Japanese Verbs (Past tense / よね) ~',
      'progress': 0,
    },
    {
      'title': 'Japanese Grammar Part 5',
      'subtitle': '~ Summary and Quizzes ~',
      'progress': 0,
    },
    {'title': 'ない です', 'subtitle': 'Negative form of です', 'progress': 0},
    {
      'title': 'を [Verb] ないで ください',
      'subtitle': 'Please do not [verb]',
      'progress': 0,
    },
    {
      'title': 'Japanese particle も (mo)',
      'subtitle': 'The particle for "also" or "too"',
      'progress': 0,
    },
    {
      'title': 'て ください',
      'subtitle': 'Polite request using te-form',
      'progress': 0,
    },
    {
      'title': 'Grammar Review 1',
      'subtitle': 'Review of lessons 1–4',
      'progress': 0,
    },
    {'title': 'て います', 'subtitle': 'Describing ongoing actions', 'progress': 0},
    {
      'title': 'How to Identify Japanese Verb Groups',
      'subtitle': 'Group 1, 2, and irregular verbs',
      'progress': 0,
    },
    {
      'title': 'Japanese Demonstratives',
      'subtitle': 'これ, それ, あれ, どれ etc.',
      'progress': 0,
    },
    {
      'title': 'Japanese particle と (to)',
      'subtitle': 'Used for "and" or quoting',
      'progress': 0,
    },
    {
      'title': 'Grammar Review 2',
      'subtitle': 'Review of lessons 5–9',
      'progress': 0,
    },
    {
      'title': 'こと です',
      'subtitle': 'Nominalizing verbs or actions',
      'progress': 0,
    },
    {
      'title': 'Japanese particle で (de)',
      'subtitle': 'Indicates means, place of action',
      'progress': 0,
    },
    {
      'title': 'Japanese particle に (ni)',
      'subtitle': 'Indicates time, destination, indirect object',
      'progress': 0,
    },
    {
      'title': 'います / あります',
      'subtitle': 'Existence verbs for animate/inanimate',
      'progress': 0,
    },
    {
      'title': 'Grammar Review 3',
      'subtitle': 'Review of lessons 10–14',
      'progress': 0,
    },
    {
      'title': 'Japanese particle の (no)',
      'subtitle': 'Indicates possession or connection',
      'progress': 0,
    },
    {
      'title': 'Japanese Particle か (ka)',
      'subtitle': 'Used for questions',
      'progress': 0,
    },
    {
      'title': '8 Important Japanese Particles',
      'subtitle': 'Overview of common particles',
      'progress': 0,
    },
    {
      'title': 'Ta-form of Japanese verbs',
      'subtitle': 'Past tense form of verbs',
      'progress': 0,
    },
    {
      'title': 'Grammar Review 4',
      'subtitle': 'Review of lessons 15–20',
      'progress': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    _progressBox = await Hive.openBox('gramQuizProgress');
    _loadProgress();
  }

  void _loadProgress() {
    setState(() {
      for (var quiz in _japaneseGrammar) {
        final savedProgress = _progressBox.get(quiz['title']);
        if (savedProgress != null) {
          quiz['progress'] = savedProgress;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title).animate().fadeIn(duration: 500.ms),
      //   centerTitle: true,
      //   elevation: 0,
      //   flexibleSpace: Container(
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         colors: [Colors.blue.shade700, Colors.blue.shade400],
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //       ),
      //     ),
      //   ),
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child:
            widget.selectedIndex == 1
                ? _buildQuizListView()
                : _buildLessonListView(),
      ),
    );
  }

  Widget _buildQuizListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _japaneseGrammar.length,
      itemBuilder: (context, index) {
        final quiz = _japaneseGrammar[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child:
              Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap:
                          () => _onTryQuiz(
                            context,
                            index + 1,
                            quiz['title'],
                            quiz['progress'],
                          ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    quiz['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ).animate().fadeIn(delay: (100 * index).ms),
                                  const SizedBox(height: 4),
                                  Text(
                                    quiz['subtitle'],
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ).animate().fadeIn(delay: (150 * index).ms),
                                ],
                              ),
                            ),
                            _buildProgressIndicator(quiz['progress'])
                                .animate()
                                .scale(delay: (200 * index).ms)
                                .shake(delay: 300.ms, hz: 4),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .slideX(
                    begin: index.isEven ? -20 : 20,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(),
        );
      },
    );
  }

  Widget _buildLessonListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 25,
      itemBuilder: (context, index) {
        final lessonNumber = index + 1;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                title: Text(
                  'Lesson $lessonNumber',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ).animate().fadeIn(delay: (50 * index).ms),
                trailing: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.blue.shade800,
                  ),
                ).animate().rotate(delay: (100 * index).ms),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: Colors.blue.shade50,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              // GrammarScreen(title: 'Lesson $lessonNumber'),
                              LessonOneHome(title: '$lessonNumber'),
                    ),
                  );
                },
              )
              .animate()
              .scaleXY(
                begin: 0.9,
                end: 1,
                delay: (75 * index).ms,
                duration: 300.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(delay: (50 * index).ms),
        );
      },
    );
  }

  Widget _buildProgressIndicator(int progress) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
                value: progress / 100,
                strokeWidth: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(progress),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(delay: 300.ms, duration: 800.ms)
              .then(delay: 1.seconds)
              .scale(end: Offset(1.1, 1.1), duration: 500.ms)
              .then()
              .scale(end: Offset(1, 1)),
          Text(
            '$progress%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getProgressColor(progress),
            ),
          ).animate().scale(delay: 200.ms),
        ],
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress < 30) return Colors.red.shade400;
    if (progress < 70) return Colors.orange.shade400;
    return Colors.green.shade500;
  }

  void _onTryQuiz(BuildContext context, index, title, progress) async {
    final updatedProgressMap = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                GramQuizePage(id: index, title: title, progress: progress),
      ),
    );

    if (updatedProgressMap != null) {
      setState(() {
        final index = _japaneseGrammar.indexWhere(
          (quiz) => quiz['title'] == updatedProgressMap['title'],
        );
        if (index != -1) {
          final updatedProgress = updatedProgressMap['progress'] as int;
          _japaneseGrammar[index]['progress'] = updatedProgress;
          _saveProgress(updatedProgressMap['title'], updatedProgress);
        }
      });
    }
  }

  void _saveProgress(String title, int progress) {
    _progressBox.put(title, progress);
  }
}
