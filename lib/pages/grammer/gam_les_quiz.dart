import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LessQuizPage extends StatefulWidget {
  final String lessonNumber;

  const LessQuizPage({super.key, required this.lessonNumber});

  @override
  State<LessQuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<LessQuizPage> {
  late List<QuizQuestion> questions;
  int currentIndex = 0;
  String? selectedAnswer;
  bool? isCorrect;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final rawJson = await rootBundle.loadString('assets/json/gram_less${widget.lessonNumber}.json');
    final List data = jsonDecode(rawJson);
    setState(() {
      questions = extractQuizQuestions(data);
      isLoading = false;
    });
  }

  void checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      isCorrect = (answer == questions[currentIndex].correctAnswer);
    });
  }

  void nextQuestion() {
    setState(() {
      currentIndex = (currentIndex + 1) % questions.length;
      selectedAnswer = null;
      isCorrect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
     if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Japanese Quiz")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              q.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            ...q.options.map(
              (opt) => ListTile(
                title: Text(opt),
                leading: Radio<String>(
                  value: opt,
                  groupValue: selectedAnswer,
                  onChanged: (val) {
                    if (val != null) checkAnswer(val);
                  },
                ),
              ),
            ),

            if (isCorrect != null)
              Text(
                isCorrect!
                    ? "✅ Correct!"
                    : "❌ Wrong! Correct: ${q.correctAnswer}",
                style: TextStyle(
                  fontSize: 18,
                  color: isCorrect! ? Colors.green : Colors.red,
                ),
              ),

            const Spacer(),
            ElevatedButton(onPressed: nextQuestion, child: const Text("Next")),
          ],
        ),
      ),
    );
  }
}

/// Data model
class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

/// Function to extract quiz questions from JSON
List<QuizQuestion> extractQuizQuestions(List data) {
  final List<QuizQuestion> quizList = [];

  for (var item in data) {
    // Extract questions from points -> examples
    if (item['points'] != null) {
      for (var p in item['points']) {
        // Multiple examples in a list
        if (p['examples'] != null) {
          for (var ex in p['examples']) {
            _addQuestionFromExample(ex, quizList);
          }
        }
        // Single example
        if (p['example'] != null) {
          _addQuestionFromExample(p['example'], quizList);
        }
      }
    }

    // Extract questions from direct examples
    if (item['example'] != null) {
      _addQuestionFromExample(item['example'], quizList);
    }

    // Extract questions from examples list
    if (item['examples'] != null) {
      for (var ex in item['examples']) {
        _addQuestionFromExample(ex, quizList);
      }
    }

    // Extract questions from dialogue
    if (item['dialogue'] != null) {
      for (var dialogue in item['dialogue']) {
        if (dialogue['japanese'] != null && dialogue['english'] != null) {
          quizList.add(
            QuizQuestion(
              question: "Translate: ${dialogue['japanese']}",
              options: ["${dialogue['english']}", "Incorrect translation 1", "Incorrect translation 2", "Incorrect translation 3"],
              correctAnswer: dialogue['english'],
            ),
          );
        }
      }
    }
  }

  return quizList;
}

void _addQuestionFromExample(dynamic example, List<QuizQuestion> quizList) {
  if (example is Map<String, dynamic>) {
    // Yes/No questions
    if (example['answer'] != null && example['answer'] is Map<String, dynamic>) {
      final answer = example['answer'] as Map<String, dynamic>;
      if (answer['japanese'] != null) {
        final isYes = answer['japanese'].toString().startsWith("はい");
        quizList.add(
          QuizQuestion(
            question: "${example['japanese']}\n(${example['english']})",
            options: ["はい", "いいえ"],
            correctAnswer: isYes ? "はい" : "いいえ",
          ),
        );
      }
    }
    
    // Multiple choice questions with answers array
    if (example['answers'] != null && example['answers'] is List) {
      final answers = example['answers'] as List;
      if (answers.isNotEmpty && answers[0] is Map<String, dynamic>) {
        final correctAnswer = answers[0]['english']?.toString() ?? '';
        if (correctAnswer.isNotEmpty) {
          quizList.add(
            QuizQuestion(
              question: "${example['japanese']}\nWhat is the correct answer?",
              options: [
                correctAnswer,
                "Incorrect option 1",
                "Incorrect option 2",
                "Incorrect option 3"
              ],
              correctAnswer: correctAnswer,
            ),
          );
        }
      }
    }
    
    // Simple translation questions
    if (example['japanese'] != null && example['english'] != null && example['answer'] == null) {
      quizList.add(
        QuizQuestion(
          question: "Translate: ${example['japanese']}",
          options: [
            example['english'],
            "Incorrect translation 1",
            "Incorrect translation 2",
            "Incorrect translation 3"
          ],
          correctAnswer: example['english'],
        ),
      );
    }
  }
}
