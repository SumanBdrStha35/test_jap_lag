import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_app/pages/voca/voca_quize.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VocaLessonDetailPage extends StatefulWidget {
  final int lessonNumber;
  final int? currentProgress;

  const VocaLessonDetailPage({super.key, required this.lessonNumber, this.currentProgress});

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
      vocabulary = jsonResponse.map<Map<String, String>>((item) {
        return {
          'kanji': item['kanji']?.toString() ?? '',
          'hiragana': item['hiragana']?.toString() ?? '',
          'meaning': item['meaning']?.toString() ?? '',
          'desc': item['desc']?.toString() ?? '',
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson ${widget.lessonNumber}'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: vocabulary.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue[50]!, Colors.white],
                    ),
                  ),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VocaQuizePage(
                              id: widget.lessonNumber,
                              title: 'Lesson ${widget.lessonNumber}',
                              progress: widget.currentProgress ?? 0,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow, size: 24),
                      label: const Text(
                        'Start Quiz',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                        backgroundColor: Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vocabulary.length,
                    itemBuilder: (context, index) {
                      final word = vocabulary[index];
                      return _buildVocabularyCard(word);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildVocabularyCard(Map<String, String> word) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word['kanji'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        word['hiragana'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.blueAccent),
                  onPressed: () => startSpeak(word['hiragana'] ?? ''),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              word['meaning'] ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if ((word['desc'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                word['desc'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> startSpeak(String s) async {
    await flutterTts.setLanguage("ja-JP");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(s);
  }
}
