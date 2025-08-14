
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FolktaleDetailPage extends StatefulWidget {
  const FolktaleDetailPage({super.key});

  @override
  State<FolktaleDetailPage> createState() => _FolktaleDetailPageState();
}

class _FolktaleDetailPageState extends State<FolktaleDetailPage> {
  final FlutterTts _flutterTts = FlutterTts();
  String? _currentlyPlayingUrl;

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _playAudio(String text) async {
    if (text.isEmpty) return;
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? folktale =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (folktale == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Folktale Detail'),
        ),
        body: const Center(
          child: Text('No folktale data found.'),
        ),
      );
    }

    final List<dynamic> content = folktale['content'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(folktale['title'] ?? 'Folktale Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (folktale['image'] != null)
              Center(
                child: Image.asset(
                  folktale['image'],
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 100),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              folktale['description'] ?? '',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              folktale['learning_info'] ?? '',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            const Text(
              'Content:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...content.map<Widget>((item) {
              final sentence = item['sentence'] ?? {};
              final List<dynamic> vocabulary = item['vocabulary'] ?? [];

              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
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
                                sentence['kanji'] ?? '',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sentence['hiragana'] ?? '',
                                style: const TextStyle(
                                    fontSize: 16, fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sentence['romaji'] ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sentence['english'] ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                    IconButton(
                      icon: Icon(
                        _currentlyPlayingUrl == sentence['hiragana']
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        size: 32,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        _playAudio(sentence['hiragana'] ?? '');
                        setState(() {
                          _currentlyPlayingUrl = sentence['hiragana'];
                        });
                      },
                    ),
                      ],
                    ),
                    if (vocabulary.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Vocabulary:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: vocabulary.map<Widget>((vocab) {
                          final kanji = vocab['kanji'] ?? '';
                          final hiragana = vocab['hiragana'] ?? '';
                          final english = vocab['english'] ?? '';
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (kanji.isNotEmpty)
                                  Text(
                                    kanji,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                if (hiragana.isNotEmpty)
                                  Text(
                                    hiragana,
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic),
                                  ),
                                if (english.isNotEmpty)
                                  Text(
                                    english,
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
