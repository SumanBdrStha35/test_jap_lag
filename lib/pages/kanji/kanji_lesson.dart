import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_app/pages/kanji/kanji_details.dart';
import 'package:flutter_app/pages/kanji/kanji_test.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logger/logger.dart';

class KanjiLessonPage extends StatefulWidget {
  final int id;
  final String name;

  const KanjiLessonPage({super.key, required this.id, required this.name});

  @override
  State<KanjiLessonPage> createState() => _KanjiLessonPageState();
}

class _KanjiLessonPageState extends State<KanjiLessonPage> {
  late Future<List<dynamic>> kanjiListFuture;
  List<dynamic>? _kanjiList;

  Future<List<dynamic>> loadKanjiData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/json/ak.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap[widget.id.toString()]?['kanji'] ?? [];
  }

  @override
  void initState() {
    super.initState();
    kanjiListFuture = loadKanjiData();
  }

  void _navigateToQuiz() {
    if (_kanjiList != null && _kanjiList!.isNotEmpty) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  KanjiQuiz(questions: _kanjiList!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade700,
        elevation: 5,
      ),
      floatingActionButton: FutureBuilder<List<dynamic>>(
        future: kanjiListFuture,
        builder: (context, snapshot) {
          final bool hasData =
              snapshot.hasData && (snapshot.data?.isNotEmpty ?? false);
          if (hasData) _kanjiList = snapshot.data;

          return FloatingActionButton.extended(
            onPressed: hasData ? _navigateToQuiz : null,
            backgroundColor: hasData ? Colors.indigo.shade700 : Colors.grey,
            icon: Icon(Icons.quiz, color: Colors.white),
            label: Text(
              'Take Quiz',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            heroTag: 'quiz_fab_${widget.id}',
          );
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.indigo.shade100],
          ),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: kanjiListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.indigo.shade700,
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading data',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 18),
                ),
              );
            } else {
              final List<dynamic> kanjiList = snapshot.data ?? [];
              if (kanjiList.isEmpty) {
                return Center(
                  child: Text(
                    'No kanji available for this lesson',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: kanjiList.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = kanjiList[index];
                  if (item is Map<String, dynamic>) {
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      KanjiDetailsPage(kanjiData: item),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kanji character with decorative container
                              Container(
                                width: 70,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.indigo.shade200,
                                      blurRadius: 2,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item['kanji'] ?? '',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${item['stroke_count'] ?? ''} strokes',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.indigo.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              // Kanji details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Onyomi reading
                                    _buildReadingRow(
                                      'Onyomi:',
                                      item['readings']['onyomi'] ?? '',
                                      Colors.red.shade700,
                                    ),
                                    SizedBox(height: 4),
                                    // Kunyomi reading
                                    _buildReadingRow(
                                      'Kunyomi:',
                                      item['readings']['kunyomi'] ?? '',
                                      Colors.blue.shade700,
                                    ),
                                    SizedBox(height: 8),
                                    // Meaning
                                    Text(
                                      'Meaning:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      item['meaning'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    // Mnemonic
                                    Text(
                                      'Mnemonic:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      item['mnemonic'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey.shade700,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: (100 * index).ms);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildReadingRow(String label, String reading, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(width: 4),
        Flexible(
          child: Text(
            reading,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
