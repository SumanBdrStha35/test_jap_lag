import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_app/pages/voca/voca_quize.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VocaLessonDetailPage extends StatefulWidget {
  final int lessonNumber;

  const VocaLessonDetailPage({super.key, required this.lessonNumber});

  @override
  _VocaLessonDetailPageState createState() => _VocaLessonDetailPageState();
}

class _VocaLessonDetailPageState extends State<VocaLessonDetailPage> {
  List<Map<String, String>> vocabulary = [];
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    loadVocabulary();
  }

  Future<void> loadVocabulary() async {
    String jsonFileName = 'assets/json/voca_les_${widget.lessonNumber}.json';
    final String jsonString = await rootBundle.loadString(jsonFileName);
    final List<dynamic> jsonResponse = json.decode(jsonString);
    setState(() {
      vocabulary =
          jsonResponse.map<Map<String, String>>((item) {
            return {
              'kanji': item['kanji']?.toString() ?? '',
              'hiragana': item['hiragana']?.toString() ?? '',
              'meaning': item['meaning']?.toString() ?? '',
              'desc': item['desc']?.toString() ?? '',
              'group': item['group']?.toString() ?? '',
            };
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          vocabulary.isEmpty
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              )
              : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Lesson ${widget.lessonNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue[800]!,
                              Colors.blue[600]!,
                              Colors.blue[400]!,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.menu_book,
                            size: 80,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Hero(
                        tag: 'quiz-button-${widget.lessonNumber}',
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        VocaQuizePage(
                                          id: widget.lessonNumber,
                                          title:
                                              'Lesson ${widget.lessonNumber}',
                                          selected: 0,
                                        ),
                                transitionsBuilder: (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow, size: 28),
                          label: const Text(
                            'Start Interactive Quiz',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 32,
                            ),
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                          ),
                        ),
                      ),
                    ).animate().scale(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final word = vocabulary[index];
                        return _buildVocabularyCard(word, index);
                      }, childCount: vocabulary.length),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildVocabularyCard(Map<String, String> word, int index) {
    String kanjiText = word['kanji'] ?? '';
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue[50]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                word['hiragana'] ?? '',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ).animate().fadeIn(
                                duration: const Duration(milliseconds: 500),
                                delay: Duration(milliseconds: 100 * index),
                              ),
                            ),
                            if (word['group'] != null && word['group']!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  'Group: ${word['group']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        kanjiText.isNotEmpty
                            ? Text(
                              kanjiText,
                              style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ).animate().slideX(
                              duration: const Duration(milliseconds: 500),
                              delay: Duration(milliseconds: 100 * index),
                              begin: -0.2,
                              end: 0,
                            )
                            : Container(),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.volume_up,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () => startSpeak(word['hiragana'] ?? ''),
                    ),
                  ).animate().scale(
                    duration: const Duration(milliseconds: 300),
                    delay: Duration(milliseconds: 100 * index),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meaning:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      word['meaning'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ).animate().fadeIn(
                duration: const Duration(milliseconds: 600),
                delay: Duration(milliseconds: 100 * index),
              ),
              if ((word['desc'] ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        word['desc'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ).animate().slideY(
                  duration: const Duration(milliseconds: 500),
                  delay: Duration(milliseconds: 100 * index),
                  begin: 0.2,
                  end: 0,
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().scale(
      duration: const Duration(milliseconds: 400),
      delay: Duration(milliseconds: 50 * index),
      curve: Curves.easeOutBack,
    );
  }

  Future<void> startSpeak(String s) async {
    await flutterTts.setLanguage("ja-JP");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(s);
  }
}
