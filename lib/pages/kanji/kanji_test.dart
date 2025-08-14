import 'package:flutter/material.dart';
import 'dart:math';

class KanjiQuiz extends StatefulWidget {
  final List<dynamic> questions;
  const KanjiQuiz({super.key, required this.questions});

  @override
  _KanjiQuizState createState() => _KanjiQuizState();
}

class _KanjiQuizState extends State<KanjiQuiz> {
  int _currentQuestion = 0;
  String _selectedAnswer = '';
  List<String> _options = [];
  String _correctAnswer = '';
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _generateOptions();
  }

  void _generateOptions() {
    final current = widget.questions[_currentQuestion];
    // final correctKunyomi = (current['readings']?['kunyomi'] ?? '').toString().split(',')[0];
    final correctKunyomi = (current['reading_kana'] ?? '').toString().split(',')[0];
    _correctAnswer = correctKunyomi;

    // Create a list of all possible wrong answers from the same lesson
    List<String> wrongAnswers = [];
    for (var question in widget.questions) {
      if (question != current) {
        // final kunyomi = (question['readings']?['kunyomi'] ?? '').toString().split(',')[0];
        final kunyomi = (question['reading_kana'] ?? '').toString().split(',');
        if (kunyomi.isNotEmpty && kunyomi[0].isNotEmpty) {
          wrongAnswers.add(kunyomi[0]);
        }
      }
    }

    // Select 3 random wrong answers
    final random = Random();
    List<String> selectedWrongAnswers = [];
    wrongAnswers.shuffle();
    for (var i = 0; i < min(3, wrongAnswers.length); i++) {
      selectedWrongAnswers.add(wrongAnswers[i]);
    }

    // Combine correct and wrong answers
    List<String> allOptions = [correctKunyomi, ...selectedWrongAnswers];
    allOptions.shuffle();

    setState(() {
      _options = allOptions;
      _showResult = false;
    });
  }

  void _selectOption(String option) {
    setState(() {
      _selectedAnswer = option;
      _showResult = true;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < widget.questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = '';
        _showResult = false;
      });
      _generateOptions();
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
        _selectedAnswer = '';
        _showResult = false;
      });
      _generateOptions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.questions[_currentQuestion];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanji Quiz'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: _previousQuestion,
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: _nextQuestion,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Question (Kanji character)
                Text(
                  current['kanji'] ?? '',
                  style: const TextStyle(
                    fontSize: 120, // Increased size significantly
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                // Options
                Column(
                  children: _options.map((option) {
                    bool isSelected = _selectedAnswer == option;
                    bool isCorrect = option == _correctAnswer;
                    Color buttonColor = Colors.white;
                    Color textColor = Colors.black;
                    Color borderColor = Colors.grey;

                    if (_showResult) {
                      if (isCorrect) {
                        buttonColor = Colors.green.shade100;
                        borderColor = Colors.green;
                        textColor = Colors.green;
                      } else if (isSelected) {
                        buttonColor = Colors.red.shade100;
                        borderColor = Colors.red;
                        textColor = Colors.red;
                      }
                    } else if (isSelected) {
                      buttonColor = Colors.blue.shade100;
                      borderColor = Colors.blue;
                    }

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          side: BorderSide(color: borderColor, width: 2),
                          padding: const EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _showResult ? null : () => _selectOption(option),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 20,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                if (_showResult)
                  Text(
                    _selectedAnswer == _correctAnswer ? 'Correct!' : 'Incorrect!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _selectedAnswer == _correctAnswer ? Colors.green : Colors.red,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestion + 1} of ${widget.questions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _showResult ? _nextQuestion : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
