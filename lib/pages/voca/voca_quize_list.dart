import 'package:flutter/material.dart';
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
    { 'id': 1, 'title': 'Nouns Part1', 'progress': 0},
    { 'id': 2, 'title': 'Nouns Part2', 'progress': 0},
    { 'id': 3, 'title': 'Nouns Part3', 'progress': 0},
    { 'id': 4, 'title': 'Nouns Part4', 'progress': 0},
    { 'id': 5, 'title': 'Nouns Part5', 'progress': 0},
    { 'id': 6, 'title': 'Nouns Part6', 'progress': 0},
    { 'id': 7, 'title': 'Nouns Part7', 'progress': 0},
    { 'id': 8, 'title': 'Nouns Part8', 'progress': 0},
    { 'id': 9, 'title': 'Nouns Part9', 'progress': 0},
    { 'id': 10, 'title': 'Nouns Part10', 'progress': 0},
    { 'id': 11, 'title': 'Nouns Part11', 'progress': 0},
    { 'id': 12, 'title': 'Adverbs', 'progress': 0},
    { 'id': 13, 'title': 'I-Adjectives', 'progress': 0},
    { 'id': 14, 'title': 'Na-Adjectives', 'progress': 0},
    { 'id': 15, 'title': 'Verbs Part1', 'progress': 0},
    { 'id': 16, 'title': 'Verbs Part2', 'progress': 0},
    { 'id': 17, 'title': 'Verbs Part3', 'progress': 0},
    { 'id': 18, 'title': 'Verbs Part4', 'progress': 0},
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

  void _onTryQuiz(BuildContext context, int id, String title, int progress) async {
    final updatedProgressMap = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => VocaQuizePage(id: id, title: title, progress: progress),
      ),
    );

    if (updatedProgressMap != null) {
      setState(() {
        final index = _quizList.indexWhere((quiz) => quiz['id'] == updatedProgressMap['id']);
        if (index != -1) {
          final updatedProgress = updatedProgressMap['progress'] as int;
          _quizList[index]['progress'] = updatedProgress;
          _saveProgress(updatedProgressMap['id'], updatedProgress);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vocabulary Quizzes'),
      ),
      body: ListView.builder(
        itemCount: _quizList.length,
        itemBuilder: (context, index) {
          final quiz = _quizList[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(quiz['title']),
              subtitle: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      value: quiz['progress'] / 100,
                      strokeWidth: 4,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('${quiz['progress']} % completed'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _onTryQuiz(context, quiz['id'], quiz['title'], quiz['progress']),
                child: Text('Try Vocab Quiz'),
              ),
              onTap: () => _onTryQuiz(context, quiz['id'], quiz['title'], quiz['progress']),
            ),
          );
        },
      ),
    );
  }
}
