import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class GramQuizePage extends StatefulWidget {
  final int? id;
  final String? title;
  final int? progress;

  const GramQuizePage({super.key, this.id, this.title, this.progress});

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
    print("widget.id: ${widget.id}");
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    quizeItems = await rootBundle.loadString(
      'assets/json/gram_part${widget.id}.json',
    );
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
      final String correctHiragana =
          currentQuestion["correct_answer"]["hiragana"];
      final String correctRomaji = currentQuestion["correct_answer"]["romaji"];
      bool isCorrect = false;

      if (selectedIndex >= 0 && selectedIndex < choices.length) {
        final selectedChoice = choices[selectedIndex];
        if (selectedChoice["hiragana"] == correctHiragana &&
            selectedChoice["romaji"] == correctRomaji) {
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
      final String correctHiragana =
          currentQuestion["correct_answer"]["hiragana"];
      final String correctRomaji = currentQuestion["correct_answer"]["romaji"];
      bool isCorrect = false;

      if (selectedIndex >= 0 && selectedIndex < choices.length) {
        final selectedChoice = choices[selectedIndex];
        if (selectedChoice["hiragana"] == correctHiragana &&
            selectedChoice["romaji"] == correctRomaji) {
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
      print(
        "Quiz completed with $correctCount correct answers out of ${questionData!.length}.",
      );
      print("Progress: $progress%");
      setState(() {
        completedCount = progress;
      });
      Navigator.pop(context, {'title': widget.title, 'progress': progress});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'Grammar Quiz'),
          backgroundColor: colorScheme.primaryContainer,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = questionData![currentQuesNo];
    final translation = currentQuestion["translation"];
    final List choices = currentQuestion["choices"];
    final String correctHiragana =
        currentQuestion["correct_answer"]["hiragana"];
    final String correctRomaji = currentQuestion["correct_answer"]["romaji"];

    Widget buildSentence(
      String label,
      String sentence0,
      String sentence1,
      String romaji,
      String correctRomaji,
    ) {
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
                  color: const Color.fromARGB(255, 182, 195, 255),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title ?? 'Grammar Quiz'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.progress != null)
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$currentQuesNo/${questionData!.length}',
                style: textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 182, 195, 255),
              const Color.fromARGB(255, 255, 184, 237),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Progress indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: currentQuesNo / questionData!.length,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 20),

                // Question card
                Expanded(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // English translation
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'English',
                                    style: textTheme.titleSmall!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    translation["english"],
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontSize: 18,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Japanese sentences
                            buildSentence(
                              "Hiragana",
                              translation["hiragana0"],
                              translation["hiragana1"],
                              selectedHiragana,
                              correctHiragana,
                            ),

                            const SizedBox(height: 16),

                            buildSentence(
                              "Romaji",
                              translation["romaji0"],
                              translation["romaji1"],
                              selectedRomaji,
                              correctRomaji,
                            ),

                            const SizedBox(height: 32),

                            // Answer choices
                            Flexible(
                              fit: FlexFit.loose,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final buttonHeight =
                                      constraints.maxHeight / 3;
                                  final buttonWidth =
                                      constraints.maxWidth / 2 - 8;

                                  return GridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio:
                                        (buttonWidth / buttonHeight),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children:
                                        choices.asMap().entries.map<Widget>((
                                          entry,
                                        ) {
                                          final int index = entry.key;
                                          final choice = entry.value;
                                          final String choiceHiragana =
                                              choice["hiragana"];
                                          final String choiceRomaji =
                                              choice["romaji"];
                                          final bool isSelected =
                                              selectedIndex == index;

                                          return _AnswerButton(
                                            kanji: choiceHiragana,
                                            romaji: choiceRomaji,
                                            isSelected: isSelected,
                                            onTap: () {
                                              setState(() {
                                                selectedIndex = index;
                                                selectedHiragana =
                                                    choiceHiragana;
                                                selectedRomaji = choiceRomaji;
                                              });
                                            },
                                          );
                                        }).toList(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Next button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedIndex == -1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please select an answer before proceeding.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      nextQuestion();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667eea),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      currentQuesNo < questionData!.length - 1
                          ? 'Next Question'
                          : 'Finish Quiz',
                      style: textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected
                  ? const Color.fromARGB(255, 255, 184, 237)
                  : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          elevation: isSelected ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          side: BorderSide(
            color:
                isSelected
                    ? const Color.fromARGB(255, 182, 195, 255)
                    : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              kanji,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              romaji,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white70 : Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
