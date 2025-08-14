import 'package:flutter/material.dart';
import 'package:flutter_app/pages/kanji/kanjiStrokeFrame.dart';
import 'package:flutter_app/pages/kanji/kanjiStrokePainter.dart';
import 'package:path_drawing/path_drawing.dart';

class KanjiDetailsPage extends StatelessWidget {
  final Map<String, dynamic> kanjiData;

  const KanjiDetailsPage({super.key, required this.kanjiData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: kanjiData['kanji'] != null
          ? Text(kanjiData['kanji'])
          : const Text('Kanji Details')),
      body: KanjiAnimationPage(kanjiData: kanjiData),
    );
  }
}

class KanjiAnimationPage extends StatefulWidget {
  final Map<String, dynamic> kanjiData;

  const KanjiAnimationPage({super.key, required this.kanjiData});

  @override
  State<KanjiAnimationPage> createState() => _KanjiAnimatorScreenState();
}

class _KanjiAnimatorScreenState extends State<KanjiAnimationPage> with SingleTickerProviderStateMixin {
  List<Path> paths = [];
  int currentStroke = 0;
  late AnimationController _controller;
  int _currentStrokeIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_currentStrokeIndex < widget.kanjiData['gif'].length - 1) {
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() => _currentStrokeIndex++);
              _controller.forward(from: 0);
            });
          } else {
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() => _currentStrokeIndex = 0);
              _controller.forward(from: 0);
            });
          }
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  List<Path> get _pathsToDraw =>
    (widget.kanjiData['gif'] as List<dynamic>)
        .take(_currentStrokeIndex + 1)
        .map((e) => parseSvgPathData(e as String))
        .toList();

  @override
  Widget build(BuildContext context) {
    final kanjiData = widget.kanjiData;
    final String kanji = kanjiData['kanji'] ?? '';
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (_, __) {
                          return CustomPaint(
                            size: const Size(200, 200),
                            painter: KanjiStrokePainter(
                              strokes: _pathsToDraw,
                              currentProgress: _controller.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Card(
                      color: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Text(
                          kanjiData['stroke_count']?.toString() ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(
                //   'Kanji: ',
                //   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                // ),
                Text(
                  kanjiData['meaning'] ?? 'N/A',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            //mnemonic and image
            const SizedBox(height: 8),
            Container(
              // color: const Color(0xFFFFF4E5),
              // padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      kanjiData['easy_image'] ?? 'assets/kanji/default.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,

                      errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 100),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/idea.png',
                            width: 20,
                            height: 20,
                            errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 100),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            kanjiData['mnemonic'] ?? 'N/A',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            //Onyomi and Kunyomi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Onyomi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kanjiData['readings']['onyomi'] ?? 'N/A',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Kunyomi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kanjiData['readings']['kunyomi'] ?? 'N/A',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Container(
            //   alignment: Alignment.center,
            //   child: Wrap(
            //     alignment: WrapAlignment.center,
            //     spacing: 8,
            //     runSpacing: 8,
            //     children: List.generate(kanjiData['gif'].length, (i) {
            //       return KanjiStrokeFrame(frameIndex: i + 1, gif: kanjiData['gif']);
            //     }),
            //   ),
            // ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: List.generate(kanjiData['gif'].length, (i) {
                return KanjiStrokeFrame(frameIndex: i + 1, gif: kanjiData['gif']);
              }),
            ),
            const SizedBox(height: 16),
            // Text(
            //   'Example:',
            //   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Builder(
                builder: (context) {
                  final examples = kanjiData['examples'];
                  if (examples != null && examples is List && examples.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: examples.map<Widget>((example) {
                        final exampleText = example['text'] ?? 'N/A';
                        final exampleMeaning = example['meaning'] ?? 'No meaning available';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exampleText,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                exampleMeaning,
                                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return const Text(
                      'No example available',
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final sentences = kanjiData['sentances'];
                      if (sentences != null && sentences is List && sentences.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: sentences.map<Widget>((sentence) {
                            final text = sentence['text'] ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                text,
                                style: const TextStyle(fontSize: 18,),
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        return const Text(
                          'No additional information available',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
