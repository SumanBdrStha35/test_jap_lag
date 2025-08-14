import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_app/pages/kanji/kanji_details.dart';
import 'package:flutter_app/pages/kanji/kanji_test.dart';

class KanjiLessonPage extends StatefulWidget {
  final int id;
  final String name;

  const KanjiLessonPage({super.key, required this.id, required this.name});

  @override
  State<KanjiLessonPage> createState() => _KanjiLessonPageState();
}

class _KanjiLessonPageState extends State<KanjiLessonPage> {
  late Future<List<dynamic>> kanjiListFuture;

  Future<List<dynamic>> loadKanjiData() async {
    final String jsonString = await rootBundle.loadString('assets/json/ak.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap[widget.id.toString()]?['kanji'] ?? [];
  }

  @override
  void initState() {
    super.initState();
    kanjiListFuture = loadKanjiData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kanji Lesson ${widget.id}'),
        actions: [
          FutureBuilder<List<dynamic>>(
            future: kanjiListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && (snapshot.data?.isNotEmpty ?? false)) {
                return IconButton(
                  icon: const Icon(Icons.quiz),
                  tooltip: 'Take Quiz',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KanjiQuiz(questions: snapshot.data!),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: kanjiListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          } else {
            final List<dynamic> kanjiList = snapshot.data ?? [];
            if (kanjiList.isEmpty) {
              return const Center(child: Text('No data available for this lesson.'));
            }
            return ListView.builder(
              itemCount: kanjiList.length,
              itemBuilder: (context, index) {
                final item = kanjiList[index];
                if (item is Map<String, dynamic>) {
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KanjiDetailsPage(kanjiData: item),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left box with menu icon and stroke count
                            Container(
                              width: 60,
                              height: 80,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(Icons.menu, size: 20, color: Colors.blue),
                                  Text(
                                    item['kanji'] ?? '',
                                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${item['stroke_count'] ?? ''} strokes',
                                    style: const TextStyle(fontSize: 14, color: Colors.blue),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Middle content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top row: level and "View How To Draw" link
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     Text(
                                  //       item['level'] ?? 'N5',
                                  //       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  //     ),
                                  //     GestureDetector(
                                  //       onTap: () {
                                  //         // Placeholder for "View How To Draw" action
                                  //       },
                                  //       child: const Text(
                                  //         'View How To Draw',
                                  //         style: TextStyle(
                                  //           fontSize: 14,
                                  //           color: Colors.blue,
                                  //           decoration: TextDecoration.underline,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // const SizedBox(height: 6),
                                  // On and Kun readings
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 16, color: Colors.black),
                                      children: [
                                        const TextSpan(
                                          text: 'On ',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(text: item['readings']['onyomi'] ?? ''),
                                      ],
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 16, color: Colors.black),
                                      children: [
                                        const TextSpan(
                                          text: 'Kun ',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(text: item['readings']['kunyomi'] ?? ''),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Example sentence with some highlighted text (bold)
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: item['mnemonic'] ?? '',
                                          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Right side icons and stroke drawing image
                            Column(
                              children: [
                                Row(
                                  children: [
                                    // IconButton(
                                    //   icon: const Icon(Icons.star_border),
                                    //   onPressed: () {
                                    //     // Placeholder for star action
                                    //   },
                                    // ),
                                    IconButton(
                                      icon: const Icon(Icons.check_circle_outline),
                                      style: IconButton.styleFrom(
                                        alignment: Alignment.topRight,
                                      ),
                                      onPressed: () {
                                        // Placeholder for check action
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (item['image'] != null && item['image'].toString().isNotEmpty)
                                  Image.asset(
                                    item['image'],
                                    width: 80,
                                    height: 40,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.image_not_supported, size: 40),
                                  )
                                else
                                  Container(width: 80, height: 40, color: Colors.grey[300]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          }
        },
      ),
    );
  }
}
