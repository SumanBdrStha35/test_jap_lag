import 'package:flutter/material.dart';
import 'package:flutter_app/pages/voca/voca_lesson_detail.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

class VocaLessonPage extends StatefulWidget {
  const VocaLessonPage({super.key});

  @override
  VocaLessonPageState createState() => VocaLessonPageState();
}

class VocaLessonPageState extends State<VocaLessonPage> {
  //store map
final Map<int, int> lessonProgress = {};
  //create a hive to store progress
  @override
  void initState() {
    super.initState();
    _loadLessonProgress();
  }
  Future<void> _loadLessonProgress() async {
    final box = await Hive.openBox('vocaLessonProgress');
    
    // Load initial data
    setState(() {
      for (var i = 1; i <= 25; i++) {
        lessonProgress[i] = box.get(i) ?? 0;
      }
    });
    
    // Set up listener for future changes
    box.listenable().addListener(() {
      setState(() {
        for (var i = 1; i <= 25; i++) {
          lessonProgress[i] = box.get(i) ?? 0;
        }
      });
    });
    Logger().d("kdfjndskjbfdjs");
  }

  Future <void> saveProgress(int lessonNumber, int progress) async {
    final box = await Hive.openBox('vocaLessonProgress');
    await box.put(lessonNumber, progress);
    setState(() {
      lessonProgress[lessonNumber] = progress;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Master Japanese Vocabulary',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '25 lessons to build your vocabulary',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 25,
                itemBuilder: (context, index) {
                  final lessonNumber = index + 1;
                  return _buildLessonCard(
                    lessonNumber: lessonNumber,
                    title: 'Lesson $lessonNumber',
                    subtitle: 'Vocabulary',
                    progress: lessonProgress[lessonNumber] ?? 0,
                    color: _getLessonColor(lessonNumber),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard({
    required int lessonNumber,
    required String title,
    required String subtitle,
    required int progress,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VocaLessonDetailPage(lessonNumber: lessonNumber),
              ),
            );
            if (result != null) {
              Logger().d("result $result");
              final id = result['id'] as int?;
              final progress = result['progress'] as int?;
              if (id != null && progress != null) {
                await saveProgress(id, progress);
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      lessonNumber.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: color,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getLessonColor(int lessonNumber) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[(lessonNumber - 1) % colors.length];
  }
}
