import 'dart:convert';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';

class KanjiQuizList extends StatelessWidget {
  //show list from 1 to 15 in card view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kanji Quiz')),
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(4, (index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return QuizLoader(score: index + 1);
                  },
                ),
              );
              Logger().i('kanji ${index + 1}');
            },
            child: Card(child: Center(child: Text('Kanji ${index + 1}'))),
          );
        }),
      ),
    );
  }
}

class QuizLoader extends StatefulWidget {
  final int score;
  const QuizLoader({super.key, required this.score});

  @override
  State<QuizLoader> createState() => _QuizLoaderState();
}

class _QuizLoaderState extends State<QuizLoader> {
  Future<Map<String, dynamic>> loadQuiz() async {
    final jsonString = await rootBundle.loadString(
      "assets/json/kanji_quiz.json",
    );
    final data = jsonDecode(jsonString);
    final exerciseKey = "Exercise ${widget.score}";
    if (data.containsKey(exerciseKey)) {
      return data[exerciseKey];
    } else {
      throw Exception("Exercise ${widget.score} not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadQuiz(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }
        final data = snapshot.data!;
        return QuizPage(title: "Kanji Exercise ${widget.score}", data: data);
      },
    );
  }
}

class QuizPage extends StatefulWidget {
  final String title;
  final Map<String, dynamic> data;

  QuizPage({super.key, required this.title, required this.data});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late String passage;
  late List questions;
  late List newWords;

  int current = 0;
  int? selected;
  int score = 0;
  bool finished = false;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    passage = widget.data["passage"];
    questions = widget.data["questions"];
    newWords = widget.data["new"];
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void selectOption(int index) {
    if (selected != null) return;
    setState(() {
      selected = index;
      if (index == questions[current]["answer"]) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (current + 1 < questions.length) {
      setState(() {
        current++;
        selected = null;
      });
    } else {
      setState(() {
        finished = true;
        if (score == questions.length) {
          _confettiController.play();
        }
      });
    }
  }

  void restartQuiz() {
    setState(() {
      current = 0;
      selected = null;
      score = 0;
      finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("JLPT Quiz")),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                finished
                    ? ListView(
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "Quiz Finished!",
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Your score: $score / ${questions.length}",
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: restartQuiz,
                                child: const Text("Restart"),
                              ),
                              const Divider(height: 40),
                              Text(
                                "📖 New Words",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...newWords.map(
                          (w) => Card(
                            child: ListTile(
                              title: Text("${w["word"]}  (${w["reading"]})"),
                              subtitle: Text(w["meaning"]),
                              trailing: IconButton(
                                icon: const Icon(Icons.volume_up),
                                onPressed: () {
                                  speak(w["word"]);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                children: _buildHighlightedTextSpans(passage),
                              ),
                            ),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                            ),
                            children: _buildHighlightedTextSpans(
                              questions[current]["text"],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(questions[current]["options"].length, (
                          i,
                        ) {
                          final option = questions[current]["options"][i];
                          final isCorrect = i == questions[current]["answer"];
                          Color color = Colors.grey.shade200;

                          if (selected != null) {
                            if (i == selected && isCorrect) {
                              color = Colors.green.shade300;
                            } else if (i == selected && !isCorrect) {
                              color = Colors.red.shade300;
                            } else if (isCorrect) {
                              color = Colors.green.shade100;
                            }
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.black,
                                minimumSize: const Size.fromHeight(48),
                              ),
                              onPressed: () => selectOption(i),
                              child: Text(
                                option,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          );
                        }),
                        const Spacer(),
                        if (selected != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: nextQuestion,
                              child: Text(
                                current + 1 == questions.length
                                    ? "Finish"
                                    : "Next",
                              ),
                            ),
                          ),
                      ],
                    ),
          ),
          if (finished && score == questions.length)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
                numberOfParticles: 30,
                gravity: 0.1,
              ),
            ),
        ],
      ),
    );
  }

  List<TextSpan> _buildHighlightedTextSpans(String text) {
    final List<TextSpan> spans = [];
    final regex = RegExp(r'【(.*?)】');
    int start = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(backgroundColor: Colors.yellow),
        ),
      );
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return spans;
  }

  void speak(w) {
    FlutterTts flutterTts = FlutterTts();
    flutterTts.setLanguage("ja-JP");
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.5);
    flutterTts.speak(w);
  }
}
