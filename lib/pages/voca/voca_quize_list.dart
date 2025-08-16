import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'voca_quize.dart';

class VocaQuizeListPage extends StatefulWidget {
  const VocaQuizeListPage({super.key});

  @override
  _VocaQuizeListPageState createState() => _VocaQuizeListPageState();
}

class _VocaQuizeListPageState extends State<VocaQuizeListPage> {
  late Box _progressBox;
  final List<Map<String, dynamic>> _quizList = [
    {
      'id': 1,
      'title': 'Nouns Part1',
      'progress': 0,
      'icon': Icons.text_snippet,
    },
    {
      'id': 2,
      'title': 'Nouns Part2',
      'progress': 0,
      'icon': Icons.text_snippet,
    },
    {
      'id': 3,
      'title': 'Nouns Part3',
      'progress': 0,
      'icon': Icons.text_snippet,
    },
    {
      'id': 4,
      'title': 'Nouns Part4',
      'progress': 0,
      'icon': Icons.text_snippet,
    },
    {
      'id': 5,
      'title': 'Nouns Part5',
      'progress': 0,
      'icon': Icons.text_snippet,
    },
    {
      'id': 6,
      'title': 'Nouns Part6',
      'progress': 0,
      'icon': Icons.text_snippet,
    },
    {
      'id': 7,
      'title': 'Nouns Part7',
      'progress': 0,
      'icon': Icons.text_snippet,
    },
    {
      'id': 8,
      'title': 'Nouns Part8',
      'progress': 0,
      'icon': Icons.text_snippet,
    },
    {
      'id': 9,
      'title': 'Nouns Part9',
      'progress': 0,
      'icon': Icons.text_snippet,
    },
    {
      'id': 10,
      'title': 'Nouns Part10',
      'progress': 0,
      'icon': Icons.text_snippet,
    },
    {
      'id': 11,
      'title': 'Nouns Part11',
      'progress': 0,
      'icon': Icons.text_snippet,
    },
    {'id': 12, 'title': 'Adverbs', 'progress': 0, 'icon': Icons.speed},
    {
      'id': 13,
      'title': 'I-Adjectives',
      'progress': 0,
      'icon': Icons.format_color_text,
    },
    {
      'id': 14,
      'title': 'Na-Adjectives',
      'progress': 0,
      'icon': Icons.format_color_text,
    },
    {
      'id': 15,
      'title': 'Verbs Part1',
      'progress': 0,
      'icon': Icons.directions_run,
    },
    {
      'id': 16,
      'title': 'Verbs Part2',
      'progress': 0,
      'icon': Icons.directions_run,
    },
    {
      'id': 17,
      'title': 'Verbs Part3',
      'progress': 0,
      'icon': Icons.directions_run,
    },
    {
      'id': 18,
      'title': 'Verbs Part4',
      'progress': 0,
      'icon': Icons.directions_run,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    _progressBox = await Hive.openBox('vocaQuizProgress');
    _loadProgress();
  }

  void _loadProgress() {
    setState(() {
      for (var quiz in _quizList) {
        final savedProgress = _progressBox.get(quiz['title']);
        if (savedProgress != null) {
          quiz['progress'] = savedProgress;
        }
      }
    });
  }

  void _saveProgress(String title, int progress) {
    _progressBox.put(title, progress);
  }

  void _onTryQuiz(
    BuildContext context,
    int id,
    String title,
    int progress,
  ) async {
    final updatedProgressMap = await Navigator.push<Map<String, dynamic>>(
      context,
      PageRouteBuilder(
        pageBuilder:
            (_, __, ___) => VocaQuizePage(
              id: id,
              title: title,
              progress: progress,
              selected: 1,
            ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: 500.ms,
      ),
    );

    if (updatedProgressMap != null) {
      setState(() {
        final index = _quizList.indexWhere(
          (quiz) => quiz['id'] == updatedProgressMap['id'],
        );
        if (index != -1) {
          final updatedProgress = updatedProgressMap['progress'] as int;
          _quizList[index]['progress'] = updatedProgress;
          _saveProgress(_quizList[index]['title'], updatedProgress);
        }
      });
    }
  }

  Color _getCategoryColor(String title) {
    if (title.contains('Nouns')) return Colors.blue.shade100;
    if (title.contains('Adverbs')) return Colors.purple.shade100;
    if (title.contains('Adjectives')) return Colors.orange.shade100;
    if (title.contains('Verbs')) return Colors.green.shade100;
    return Colors.grey.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Quizzes'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade600, Colors.blue.shade400],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blue],
            stops: [0.1, 0.9],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _quizList.length,
          itemBuilder: (context, index) {
            final quiz = _quizList[index];
            return _buildQuizCard(quiz, index);
          },
        ),
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz, int index) {
    final categoryColor = _getCategoryColor(quiz['title']);

    return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap:
                () => _onTryQuiz(
                  context,
                  quiz['id'],
                  quiz['title'],
                  quiz['progress'],
                ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [categoryColor.withOpacity(0.3), Colors.white],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon with progress ring
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: quiz['progress'] / 100,
                            strokeWidth: 4,
                            backgroundColor: Colors.grey.shade300,
                            color: Colors.blue,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: categoryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            quiz['icon'],
                            color: Colors.blue.shade800,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Quiz info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${quiz['progress']}% completed',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Try button
                    ElevatedButton(
                          onPressed:
                              () => _onTryQuiz(
                                context,
                                quiz['id'],
                                quiz['title'],
                                quiz['progress'],
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'Start',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                        .animate(delay: (100 * index + 200).ms)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                          curve: Curves.elasticOut,
                        ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: (100 * index).ms)
        .fadeIn()
        .slideY(begin: 20, end: 0, curve: Curves.easeOutCubic);
  }
}
