import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VocaQuizePage extends StatefulWidget {
  final int? id;
  final String? title;
  final int? progress;

  const VocaQuizePage({super.key, this.id, this.title, this.progress});

  @override
  State<VocaQuizePage> createState () => _VocaQuizePageNoun1();
}

class _VocaQuizePageNoun1 extends State<VocaQuizePage> {
  bool _quizStarted = false;
  List<Map<String, dynamic>> _quizItems = [];
  int _completedCount = 0;
  late String quizItems;

  int _currentQuestionIndex = 0;
  List<String> _options = [];
  String? _selectedOption;

  FlutterTts flutterTts = FlutterTts();
  
  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ja-JP");
    loadHive();
    _loadQuizItems();
  }

  Future<void> loadHive() async {
    final box = await Hive.openBox('vocaLessonProgress');
  }

  Future<void> _loadQuizItems() async {
    quizItems = await rootBundle.loadString('assets/json/voca_les_${widget.id}.json');
    final List<dynamic> jsonResponse = json.decode(quizItems);
    setState(() {
      _quizItems = jsonResponse.cast<Map<String, dynamic>>();
      _completedCount = widget.progress ?? 0;
    });
    _generateOptions();
  }

  void _startQuiz() {
    setState(() {
      _quizStarted = true;
    });
  }

  void _generateOptions() {
    if (_quizItems.isEmpty) return;

    final correctAnswer = _quizItems[_currentQuestionIndex]['meaning'] ?? '';
    final optionsSet = <String>{correctAnswer};

    final random = DateTime.now().millisecondsSinceEpoch;
    final randomGenerator = Random(random);

    while (optionsSet.length < 4 && optionsSet.length < _quizItems.length) {
      final randomIndex = randomGenerator.nextInt(_quizItems.length);
      final option = _quizItems[randomIndex]['meaning'] ?? '';
      optionsSet.add(option);
    }

    final optionsList = optionsSet.toList();
    optionsList.shuffle();

    setState(() {
      _options = optionsList;
      _selectedOption = null;
    });
  }

  int correctCount = 0;
  void _completeQuiz() async {
    int progress = ((correctCount / _quizItems.length) * 100).toInt();
    print('Correct: $correctCount, total: ${_quizItems.length}, progress: $progress%');
    
    // Store progress of widget.id in Hive
    final box = await Hive.openBox('vocaLessonProgress');
    //update the progress of the lesson
    await box.put(widget.id, progress); 
    
    setState(() {
      _completedCount = progress;
      _quizStarted = false;
    });
    Navigator.pop(context, {'id': widget.id, 'progress': progress});
  }

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quizItems.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
      });
      _generateOptions();
    } else {
      _completeQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedOption = null;
      });
      _generateOptions();
    }
  }

  speak(String text) async {
    try {
      await flutterTts.setLanguage("ja-JP");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      await flutterTts.awaitSpeakCompletion(true);
      var result = await flutterTts.speak(text);
      if (result == 1) {
        print("Speech started successfully");
      } else {
        print("Speech failed to start");
      }      
    } catch (e) {
      print("Error in TTS speak: \$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Vocabulary Quiz'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.deepPurple.shade100,
              Colors.white,
            ],
          ),
        ),
        child: _buildQuizInterface()
        // _quizStarted
        //     ? _buildQuizInterface()
        //     : _buildPreQuizInterface(),
      ),
    );
  }

  Widget _buildQuizInterface() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _quizItems.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressIndicator(),
                SizedBox(height: 20),
                _buildQuestionCard(),
                SizedBox(height: 20),
                _buildOptionsList(),
                Spacer(),
                _buildNavigationButtons(),
              ],
            ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_quizItems.length}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _quizItems.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final currentItem = _quizItems[_currentQuestionIndex];
    
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${currentItem['kanji']}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.volume_up, size: 32, color: Colors.deepPurple),
                onPressed: () {
                  speak(currentItem['hiragana']);
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${currentItem['hiragana']}',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Select the correct meaning:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList() {
    return Column(
      children: _options.map((option) {
        final isSelected = option == _selectedOption;
        final isCorrect = option == (_quizItems[_currentQuestionIndex]['meaning'] ?? '');
        
        Color cardColor = Colors.white;
        Color textColor = Colors.grey.shade800;
        Color borderColor = Colors.grey.shade300;
        
        if (_selectedOption != null) {
          if (isSelected && isCorrect) {
            correctCount++;
            cardColor = Colors.green.shade50;
            borderColor = Colors.green;
            textColor = Colors.green.shade800;
          } else if (isSelected && !isCorrect) {
            cardColor = Colors.red.shade50;
            borderColor = Colors.red;
            textColor = Colors.red.shade800;
          } 
          // else if (isCorrect) {
          //   correctCount += 1;
          //   cardColor = Colors.green.shade50;
          //   borderColor = Colors.green;
          //   textColor = Colors.green.shade800;
          // }
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            onTap: _selectedOption == null ? () => _selectOption(option) : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedOption == null
                          ? Colors.grey.shade300
                          : (isSelected && isCorrect)
                              ? Colors.green
                              : (isSelected && !isCorrect)
                                  ? Colors.red
                                  : isCorrect
                                      ? Colors.green
                                      : Colors.grey.shade300,
                    ),
                    child: _selectedOption != null && isCorrect
                        ? Icon(Icons.check, size: 16, color: Colors.white)
                        : _selectedOption != null && isSelected && !isCorrect
                            ? Icon(Icons.close, size: 16, color: Colors.white)
                            : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
            icon: Icon(Icons.arrow_back),
            label: Text('Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade100,
              foregroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _selectedOption != null ? _nextQuestion : null,
            icon: Icon(_currentQuestionIndex < _quizItems.length - 1
                ? Icons.arrow_forward
                : Icons.check_circle),
            label: Text(_currentQuestionIndex < _quizItems.length - 1
                ? 'Next'
                : 'Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreQuizInterface() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.school,
                    size: 64,
                    color: Colors.deepPurple,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Vocabulary Quiz',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.title}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 24),
                  if (_quizItems.isNotEmpty)
                    Text(
                      '${_quizItems.length} words to practice',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _quizStarted ? null : _startQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Start Quiz',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            if (_quizItems.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _quizItems.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final item = _quizItems[index];
                    return Container(
                      width: 150,
                      margin: EdgeInsets.only(right: 12),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${item['kanji']}',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${item['hiragana']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8),
                              IconButton(
                                icon: Icon(Icons.volume_up,
                                    color: Colors.deepPurple),
                                onPressed: () {
                                  speak(item['hiragana']);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
