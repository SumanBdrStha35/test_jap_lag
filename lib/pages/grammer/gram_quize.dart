import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class GramQuizePage extends StatefulWidget {
  final String? title;
  final int? progress;

  const GramQuizePage({super.key, this.title, this.progress});

  @override
  State<GramQuizePage> createState() => _GramQuizePageState();
}

class _GramQuizePageState extends State<GramQuizePage> {
  List<Map<String, dynamic>>? questionData;
  int selectedIndex = -1;
  String selectedHiragana = '';
  String selectedRomaji = '';
  bool _isLoading = true;
  int currentQuesNo = 1;
  int correctCount = 0;
  int completedCount = 0;
  late String quizeItems;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    if (widget.title == "Japanese Grammar Part 1") {
      quizeItems = await rootBundle.loadString('assets/json/gram_part1.json');
    } else if (widget.title == "Japanese Grammar Part 2") {
      quizeItems = await rootBundle.loadString('assets/json/gram_part2.json');
    } else {
      quizeItems = await rootBundle.loadString('assets/json/gram_part1.json');
    }
      
    final List<dynamic> jsonData = json.decode(quizeItems);
    setState(() {
      questionData = jsonData.cast<Map<String, dynamic>>();
      completedCount = widget.progress ?? 0;
      _isLoading = false;
    });
  }

  //nextQuestion     
  void nextQuestion() {
    if (currentQuesNo < (questionData!.length - 1)) {
      // Check if the selected answer is correct before moving to next question
      final currentQuestion = questionData![currentQuesNo];
      final List choices = currentQuestion["choices"];
      final String correctHiragana = currentQuestion["correct_answer"]["hiragana"];
      final String correctRomaji = currentQuestion["correct_answer"]["romaji"];
      bool isCorrect = false;

      if (selectedIndex >= 0 && selectedIndex < choices.length) {
        final selectedChoice = choices[selectedIndex];
        if (selectedChoice["hiragana"] == correctHiragana && selectedChoice["romaji"] == correctRomaji) {
          isCorrect = true;
        }
      }

      if (isCorrect) {
        setState(() {
          correctCount += 1;
        });
      }

      setState(() {
        currentQuesNo += 1;
        selectedIndex = -1;
        selectedHiragana = '';
        selectedRomaji = '';
      });
    } else {
      // Check the last question's answer correctness before finishing
      final currentQuestion = questionData![currentQuesNo];
      final List choices = currentQuestion["choices"];
      final String correctHiragana = currentQuestion["correct_answer"]["hiragana"];
      final String correctRomaji = currentQuestion["correct_answer"]["romaji"];
      bool isCorrect = false;

      if (selectedIndex >= 0 && selectedIndex < choices.length) {
        final selectedChoice = choices[selectedIndex];
        if (selectedChoice["hiragana"] == correctHiragana && selectedChoice["romaji"] == correctRomaji) {
          isCorrect = true;
        }
      }

      if (isCorrect) {
        setState(() {
          correctCount += 1;
        });
      }

      //get progress and return to previous page
      int progress = ((correctCount / questionData!.length) * 100).round();
      print("Quiz completed with $correctCount correct answers out of ${questionData!.length}.");
      print("Progress: $progress%");
      setState(() {
        completedCount = progress;
      });
      Navigator.pop(context, {
        'title': widget.title,
        'progress': progress,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const blueColor = Color(0xFF3B82F6);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'Grammar Quiz'),
          backgroundColor: colorScheme.primaryContainer,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentQuestion = questionData![currentQuesNo];
    final translation = currentQuestion["translation"];
    final List choices = currentQuestion["choices"];
    final String correctHiragana = currentQuestion["correct_answer"]["hiragana"];
    final String correctRomaji = currentQuestion["correct_answer"]["romaji"];

    Widget buildSentence(String label, String sentence0, String sentence1, String romaji, String correctRomaji) {
      String suffix = romaji.isEmpty ? " _?_" : " $romaji";
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: RichText(
          text: TextSpan(
            style: textTheme.bodyLarge!.copyWith(height: 1.5),
            children: [
              TextSpan(
                text: "$label: ",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: sentence0,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: suffix,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
              TextSpan(
                text: sentence1,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Grammar Quiz'),
        actions: [
          if (widget.progress != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '$currentQuesNo/10',
                  style: textTheme.titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              )
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'English: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface),
                                  ),
                                  TextSpan(
                                      text: translation["english"],
                                      style: TextStyle(
                                          color: colorScheme.onSurface)),
                                ],
                              ),
                              style: textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            buildSentence("Hiragana", translation["hiragana0"], translation["hiragana1"],
                                selectedHiragana, correctHiragana),
                            const SizedBox(height: 8),
                            buildSentence("Romaji", translation["romaji0"], translation["romaji1"],
                                selectedRomaji, correctRomaji),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 220,
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.5,
                          children: choices.asMap().entries.map<Widget>((entry) {
                            final int index = entry.key;
                            final choice = entry.value;
                            final String choiceHiragana = choice["hiragana"];
                            final String choiceRomaji = choice["romaji"];
                            final bool isSelected = selectedIndex == index;
                            final bool isCorrect = choiceRomaji == correctRomaji;
                            return _AnswerButton(
                              kanji: choiceHiragana,
                              romaji: choiceRomaji,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                  selectedHiragana = choiceHiragana;
                                  selectedRomaji = choiceRomaji;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedIndex == -1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select an answer before proceeding.')),
                        );
                        return;
                      }
                      nextQuestion ();
                    },
                    child: Text(
                      currentQuesNo < 10 ? 'Next Question' : 'Finish Quiz',
                      style: textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget{
  final String kanji;
  final String romaji;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.kanji,
    required this.romaji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final blueColor = const Color(0xFF3B82F6);

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? blueColor : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        minimumSize: const Size(70, 70),
        animationDuration: const Duration(milliseconds: 200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              kanji,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              romaji,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white70 : Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
