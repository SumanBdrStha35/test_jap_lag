import 'package:flutter/material.dart';
import 'package:flutter_app/pages/kanji/kanjiStrokeFrame.dart';
import 'package:flutter_app/pages/kanji/kanjiStrokePainter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:flutter_animate/flutter_animate.dart';

class KanjiDetailsPage extends StatelessWidget {
  final Map<String, dynamic> kanjiData;

  const KanjiDetailsPage({super.key, required this.kanjiData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          kanjiData['kanji'] ?? 'Kanji Details',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.indigo.shade700, Colors.indigo.shade500],
            ),
          ),
        ),
      ),
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

class _KanjiAnimatorScreenState extends State<KanjiAnimationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentStrokeIndex = 0;
  bool _showStrokeOrder = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentStrokeIndex < widget.kanjiData['gif'].length - 1) {
          Future.delayed(const Duration(milliseconds: 200), () {
            setState(() => _currentStrokeIndex++);
            _controller.forward(from: 0);
          });
        } else {
          Future.delayed(const Duration(milliseconds: 500), () {
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

  void _toggleStrokeOrder() {
    setState(() {
      _showStrokeOrder = !_showStrokeOrder;
    });
  }

  @override
  Widget build(BuildContext context) {
    final kanjiData = widget.kanjiData;
    final String kanji = kanjiData['kanji'] ?? '';
    final strokeCount = kanjiData['stroke_count']?.toString() ?? '';
    final examples = kanjiData['examples'] is List ? kanjiData['examples'] : [];
    final sentences =
        kanjiData['sentences'] is List ? kanjiData['sentences'] : [];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo.shade50, Colors.indigo.shade100],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Kanji Animation Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Center(
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
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.shade600,
                              Colors.indigo.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.shade300,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '$strokeCount strokes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ).animate().scale(delay: 300.ms),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      kanjiData['meaning'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade900,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

            // Mnemonic Section
            if (kanjiData['mnemonic'] != null ||
                kanjiData['easy_image'] != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lightbulb_outline,
                              color: Colors.amber.shade800,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Mnemonic',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (kanjiData['easy_image'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            kanjiData['easy_image']!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                      if (kanjiData['mnemonic'] != null) ...[
                        if (kanjiData['easy_image'] != null)
                          const SizedBox(height: 16),
                        Text(
                          kanjiData['mnemonic']!,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            // Readings Section
            Row(
              children: [
                Expanded(
                  child: _buildReadingCard(
                    title: '音読み (Onyomi)',
                    reading: kanjiData['readings']['onyomi'] ?? 'N/A',
                    color: Colors.red.shade600,
                    icon: Icons.volume_up,
                    delay: 300,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReadingCard(
                    title: '訓読み (Kunyomi)',
                    reading: kanjiData['readings']['kunyomi'] ?? 'N/A',
                    color: Colors.blue.shade600,
                    icon: Icons.volume_down,
                    delay: 400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stroke Order Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stroke Order',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _showStrokeOrder ? Icons.grid_view : Icons.list,
                            color: Colors.indigo.shade600,
                          ),
                          onPressed: _toggleStrokeOrder,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _showStrokeOrder
                        ? GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                          itemCount: kanjiData['gif'].length,
                          itemBuilder: (context, index) {
                            return KanjiStrokeFrame(
                              frameIndex: index + 1,
                              gif: kanjiData['gif'],
                            );
                          },
                        )
                        : Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 5,
                          runSpacing: 5,
                          children: List.generate(kanjiData['gif'].length, (i) {
                            return KanjiStrokeFrame(
                              frameIndex: i + 1,
                              gif: kanjiData['gif'],
                            );
                          }),
                        ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

            // Examples Section
            if (examples.isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.format_quote,
                              color: Colors.green.shade800,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Examples',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...examples.map<Widget>((example) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    example['text'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    example['meaning'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  if (example != examples.last)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Divider(
                                        height: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                ],
                              ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                              //speaker
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  Icons.volume_up,
                                  color: Colors.indigo.shade600,
                                ),
                                onPressed: () {
                                  speak(example['text']);
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

            // Sentences Section
            if (sentences.isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.purple.shade800,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sentences',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...sentences.map<Widget>((sentence) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            sentence['text'] ?? '',
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingCard({
    required String title,
    required List<dynamic> reading,
    required Color color,
    required IconData icon,
    required int delay,
  }) {
    return InkWell(
      onTap: () {
        //speak the reading part of the kanji
        speak(reading.join(", "));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                reading.join(", "),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1, end: 0),
    );
  }

  void speak(example) {
    FlutterTts flutterTts = FlutterTts();
    flutterTts.setLanguage("ja-JP");
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.5);
    flutterTts.speak(example);
  }
}
