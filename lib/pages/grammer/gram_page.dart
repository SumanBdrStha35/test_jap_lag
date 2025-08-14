import 'package:flutter/material.dart';
import 'package:flutter_app/pages/grammer/gramScreen.dart';
import 'package:flutter_app/pages/grammer/gram_quize.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GramPage extends StatefulWidget {
  final String title;

  const GramPage({super.key, required this.title});
  
  @override
  State<GramPage> createState() => _GramPageState();
}

class _GramPageState extends State<GramPage> {
  int selectedIndex = 0;
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
    {
      'title': 'ない です',
      'subtitle': 'Negative form of です',
      'progress': 0,
    },
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
    {
      'title': 'て います',
      'subtitle': 'Describing ongoing actions',
      'progress': 0,
    },
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
    return WillPopScope(
      onWillPop: () async {
        if (selectedIndex == 1 || selectedIndex == 2) {
          setState(() {
            selectedIndex = 0;
          });
          return false; // Prevent pop
        }
        return true; // Allow pop
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: selectedIndex == 0
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Card(
                      child: ListTile(
                        title: Text(
                          'Japanese Grammer',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          setState(() {
                            selectedIndex = 1;
                          });
                        },
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('Grammer with Lesson wise',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          setState(() {
                            selectedIndex = 2;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            : selectedIndex == 1
                ? ListView.builder(
                    itemCount: _japaneseGrammar.length,
                    itemBuilder: (context, index) {
                      final quiz = _japaneseGrammar[index];
                      return Card(
                        margin: const EdgeInsets.all(16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            quiz['title'],
                            style: const TextStyle( fontSize: 18, fontWeight: FontWeight.w600,)
                          ),
                          subtitle: Text(
                            quiz['subtitle'],
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          trailing: SizedBox(
                            width: 40,
                            height: 40,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: quiz['progress'] / 100,
                                  strokeWidth: 4,
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.blue,
                                ),
                                Text(
                                  '${quiz['progress']}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            _onTryQuiz(context, quiz['title'], quiz['progress']);
                          },
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: 25, // Assuming 25 lessons
                    itemBuilder: (context, index) {
                      final lessonNumber = index + 1;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          title: Text(
                            'Lesson $lessonNumber',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GrammarScreen(
                                  title: 'Lesson $lessonNumber',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
  
  void _onTryQuiz(BuildContext context, title, progress) async{
    final updatedProgressMap = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => GramQuizePage(title: title, progress: progress),
      ),
    );

    if (updatedProgressMap != null) {
      setState(() {
        final index = _japaneseGrammar.indexWhere((quiz) => quiz['title'] == updatedProgressMap['title']);
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
