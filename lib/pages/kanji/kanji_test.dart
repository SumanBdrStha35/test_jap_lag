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
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _generateOptions();
  }

  void _generateOptions() {
    final current = widget.questions[_currentQuestion];
    final correctKunyomi =
        (current['reading_kana'] ?? '').toString().split(',')[0];
    _correctAnswer = correctKunyomi;

    List<String> wrongAnswers = [];
    for (var question in widget.questions) {
      if (question != current) {
        final kunyomi = (question['reading_kana'] ?? '').toString().split(',');
        if (kunyomi.isNotEmpty && kunyomi[0].isNotEmpty) {
          wrongAnswers.add(kunyomi[0]);
        }
      }
    }

    final random = Random();
    List<String> selectedWrongAnswers = [];
    wrongAnswers.shuffle();
    for (var i = 0; i < min(3, wrongAnswers.length); i++) {
      selectedWrongAnswers.add(wrongAnswers[i]);
    }

    List<String> allOptions = [correctKunyomi, ...selectedWrongAnswers];
    allOptions.shuffle();

    setState(() {
      _options = allOptions;
      _showResult = false;
      _selectedAnswer = '';
    });
  }

  void _selectOption(String option) {
    setState(() {
      _selectedAnswer = option;
      _showResult = true;
      if (option == _correctAnswer) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < widget.questions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
      _generateOptions();
    } else {
      _showResultsDialog();
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
        if (_selectedAnswer == _correctAnswer) {
          _correctCount--;
        }
      });
      _generateOptions();
    }
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Quiz Completed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You got $_correctCount out of ${widget.questions.length} correct!',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _correctCount / widget.questions.length,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.indigo,
                  minHeight: 10,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  //close dialog and go back to KanjiLessonPage
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Finish'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kanji Quiz',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade200,
        elevation: 5,
        actions: [
          //skip the question
          IconButton(
            tooltip: 'Skip',
            icon: const Icon(Icons.skip_next, color: Colors.white),
            onPressed: _nextQuestion,
          ),

          // IconButton(
          //   icon: const Icon(Icons.navigate_before, color: Colors.white),
          //   onPressed: _previousQuestion,
          // ),
          // IconButton(
          //   icon: const Icon(Icons.navigate_next, color: Colors.white),
          //   onPressed: _nextQuestion,
          // ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.indigo.shade100],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                color: Colors.indigo,
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                'Question ${_currentQuestion + 1} of ${widget.questions.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
              const SizedBox(height: 16),
              // Main quiz card
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Kanji character
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.indigo.shade200,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            current['kanji'] ?? '',
                            style: const TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Meaning (hint)
                        Text(
                          current['meaning'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Options
                        Column(
                          children:
                              _options.map((option) {
                                bool isSelected = _selectedAnswer == option;
                                bool isCorrect = option == _correctAnswer;
                                Color buttonColor = Colors.white;
                                Color textColor = Colors.black;
                                Color borderColor = Colors.grey.shade400;

                                if (_showResult) {
                                  if (isCorrect) {
                                    buttonColor = Colors.green.shade100;
                                    borderColor = Colors.purple;
                                    textColor = Colors.green.shade800;
                                  } else if (isSelected && !isCorrect) {
                                    buttonColor = Colors.red.shade100;
                                    borderColor = Colors.red;
                                    textColor = Colors.red.shade800;
                                  }
                                } else if (isSelected) {
                                  buttonColor = Colors.blue.shade100;
                                  borderColor = Colors.blue;
                                  textColor = Colors.blue.shade800;
                                }

                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonColor,
                                      side: BorderSide(
                                        color: borderColor,
                                        width: 2,
                                      ),
                                      padding: const EdgeInsets.all(16.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed:
                                        _showResult
                                            ? null
                                            : () => _selectOption(option),
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 16),
                        // Result feedback
                        if (_showResult)
                          Column(
                            children: [
                              Text(
                                _selectedAnswer == _correctAnswer
                                    ? 'Correct!'
                                    : 'Incorrect!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _selectedAnswer == _correctAnswer
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Correct answer: $_correctAnswer',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        // Next button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _showResult ? _nextQuestion : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _currentQuestion < widget.questions.length - 1
                                  ? 'Next Question'
                                  : 'Finish Quiz',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
