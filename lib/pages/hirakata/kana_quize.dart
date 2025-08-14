import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

class KanaQuize extends StatelessWidget {
  final String title;
  final Map<String, String>? kanaType;
  final int maxChar;

  const KanaQuize({super.key, 
    required this.title,
    required this.kanaType,
    required this.maxChar,
  });

  @override
  Widget build(BuildContext context) {
    if (title == "Irregular Kana") {
      return IrregularApp(title: title);
    } else if(title == "Draw Kana") {
      return _WritingTest(title: title);
    } else {
      return _KanaQuize(kanaType: kanaType, maxChar: maxChar, title: title,);
    }
  }
}

class _WritingTest extends StatelessWidget {
  final String title;

  const _WritingTest({required this.title});

  @override
  Widget build(BuildContext context) {
    // Placeholder widget for "Draw Kana" mode
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'Draw Kana mode coming soon!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class _KanaQuize extends StatefulWidget{
   final String title;
  final Map<String, String>? kanaType;
  final int maxChar;

  const _KanaQuize({
    required this.title,
    required this.kanaType,
    required this.maxChar
  });

  @override
  State<_KanaQuize> createState() => _KanaQuizeState();
}

class _KanaQuizeState extends State<_KanaQuize> {
  int correct = 0;
  int incorrect = 0;
  String question = '';
  List<String> allButtonLabels = [];
  List<String> visibleButtonLabels = [];
  int optionPage = 0;
  String? correctAnswer;
  bool dialogOpen = false;
  String dialogStatus = '';
  late List<String> availableRomaji;

  String? selectedAnswer; // Track selected answer for coloring buttons

  Timer? _timer;
  int elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    availableRomaji = widget.kanaType?.keys.toList() ?? [];
    startTimer();
    generateQuestion();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
      });
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Column(
                children: [
                  Text('Progress', style: TextStyle(fontSize: 18, color: Colors.blue)),
                  Text('${correct + incorrect}/${widget.maxChar}', style: TextStyle(fontSize: 18, color: Colors.blue)),
                  SizedBox(height: 8),
                  Text('Time elapsed', style: TextStyle(fontSize: 18, color: Colors.blue)),
                  Text(formatElapsedTime(elapsedSeconds), style: TextStyle(fontSize: 18, color: Colors.blue)),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('Correct', style: TextStyle(fontSize: 18, color: Colors.green)),
                      Text('$correct', style: TextStyle(fontSize: 18, color: Colors.green)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Incorrect', style: TextStyle(fontSize: 18, color: Colors.red)),
                      Text('$incorrect', style: TextStyle(fontSize: 18, color: Colors.red)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                question,
                style: TextStyle(fontSize: 48, color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Expanded(
                child: Center(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    shrinkWrap: true,
                    padding: EdgeInsets.all(16),
                    children: visibleButtonLabels.map((label) {
                      return ElevatedButton(
                        onPressed: () => onButtonPressed(label),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedAnswer == null
                              ? Colors.blue
                              : label == correctAnswer
                                  ? Colors.green
                                  : label == selectedAnswer
                                      ? Colors.red
                                      : Colors.blue,
                          minimumSize: Size(100, 100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          label.replaceAll('_', ''),
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  String formatElapsedTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void generateQuestion() {
    if (availableRomaji.isEmpty || correct + incorrect >= widget.maxChar) {
      // Quiz complete
      stopTimer();
      // Show dialog with congratulations and options to restart or go back
      String message;
      String title;
      String lottiePath;

      final scoreRatio = correct / widget.maxChar;

      if (correct == widget.maxChar) {
        title = "🎉 Perfect!";
        message = "Amazing! You scored $correct out of ${widget.maxChar}. You're a Kana master!";
        lottiePath = 'assets/lottie/perfect.json';
      } else if (scoreRatio >= 0.9) {
        title = "🎉 Congratulations!";
        message = "Excellent! You scored $correct out of ${widget.maxChar}. You're a Kana master!";
        lottiePath = 'assets/lottie/excellent.json';
      } else if (scoreRatio >= 0.75) {
        title = "👍 Great Job!";
        message = "Good job! You scored $correct out of ${widget.maxChar}. Keep it up!";
        lottiePath = 'assets/lottie/great.json';
      } else if (scoreRatio >= 0.5) {
        title = "👏 Keep Going!";
        message = "Not bad! You scored $correct out of ${widget.maxChar}. You're getting there.";
        lottiePath = 'assets/lottie/good.json';
      } else {
        title = "💪 Keep Practicing!";
        message = "You scored $correct out of ${widget.maxChar}. Don't give up—practice makes perfect!";
        lottiePath = 'assets/lottie/sad.json';
      }
      Dialogs.materialDialog(
        context: context,
        barrierDismissible: false,
        title: 'Quiz Complete',
        color: Colors.white,
        lottieBuilder: Lottie.asset(
          lottiePath,
          height: 120,
        ),
        msg: message,
        actions: [
          IconsButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                correct = 0;
                incorrect = 0;
                elapsedSeconds = 0;
                availableRomaji = widget.kanaType?.keys.toList() ?? [];
                startTimer();
                generateQuestion();
              });
            },
            text: 'Restart',
            iconData: Icons.restart_alt,
            color: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
          IconsButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            text: 'Back',
            iconData: Icons.arrow_back,
            color: Colors.grey,
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ],
      );
      return;
    }
    // Pick a random romaji from availableRomaji
    final random = Random();
    final romajiToAsk = availableRomaji[random.nextInt(availableRomaji.length)];
    final kanaCharacter = widget.kanaType != null ? widget.kanaType![romajiToAsk] ?? '' : '';

    if (kanaCharacter == '' || kanaCharacter.isEmpty) {
      // Skip empty kanaCharacter and pick another question
      generateQuestion();
      return;
    }

    // Filter options for plausible choices
    final options = generateOptions(romajiToAsk, widget.kanaType ?? {}, 4);

    print('Question: $kanaCharacter');
    print('Correct Answer: $romajiToAsk');
    print('Options: $options');
    // Update state with the new question and options
    setState(() {
      question = kanaCharacter;
      correctAnswer = romajiToAsk;
      allButtonLabels = options;
      optionPage = 0;
      visibleButtonLabels = allButtonLabels.sublist(0, 4);
    });
  }

  List<String> generateOptions(String correctRomaji, Map<String, String> allKana, int optionCount) {
    // Gather candidate romaji keys excluding the correct answer and keys starting with "_empty"
    final allKeys = allKana.keys.where((k) => k != correctRomaji && !k.startsWith('_empty')).toList();

    // Similarity filters inspired by original React logic
    final similar = allKeys.where((key) {
      final cr = correctRomaji.replaceAll('_', '');
      final k = key.replaceAll('_', '');

      // Conditions with some randomness for variety:
      final random = Random();
      if (random.nextDouble() < 0.1) return true;
      if (cr.isNotEmpty && k.isNotEmpty && cr[0] == k[0]) return true;
      if (cr.split('').any((ch) => k.contains(ch))) return true;
      if (cr.length == k.length) return true;
      return false;
    }).toList();
    final random = Random();
    final List<String> chosenOptions = [];
    // Pick from similar first
    while (chosenOptions.length < optionCount - 1 && similar.isNotEmpty) {
      final idx = random.nextInt(similar.length);
      chosenOptions.add(similar.removeAt(idx));
    }
    // Fill remaining from allKeys randomly if needed
    var remaining = allKeys.where((k) => !chosenOptions.contains(k)).toList();
    while (chosenOptions.length < optionCount - 1 && remaining.isNotEmpty) {
      final idx = random.nextInt(remaining.length);
      chosenOptions.add(remaining.removeAt(idx));
    }
    // Add the correct answer at a random position
    final insertPos = random.nextInt(optionCount);
    chosenOptions.insert(insertPos, correctRomaji);
    // If there are more than optionCount due to insert, trim it
    if (chosenOptions.length > optionCount) {
      chosenOptions.removeLast();
    }
    return chosenOptions;
  }

  void onButtonPressed(String answer) async{
    final isCorrect = answer == correctAnswer;
    setState(() {
      selectedAnswer = answer;
    });
    if (isCorrect) {
      // await correctSound.resume();
      setState(() {
        correct++;
      });
    } else {
      // await incorrectSound.resume();
      setState(() {
        incorrect++;
      });
    }

    // Remove this question from available to ask again
    setState(() {
      availableRomaji.remove(correctAnswer);
    });

    // Delay before generating next question to show color feedback
    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        selectedAnswer = null;
      });
      generateQuestion();
    });
  }

  void closeDialog() {
    setState(() {
      dialogOpen = false;
    });
    generateQuestion();
  }
}

// Irregular
class IrregularApp extends StatefulWidget {
  final String title;

  const IrregularApp({super.key, 
    required this.title,
  });

  @override
  State<IrregularApp> createState() => _IrregularApp();
}

class _IrregularApp extends State<IrregularApp> with SingleTickerProviderStateMixin {
  final List<Question> _questions = [
    Question("しゃ", "sha"),
    Question("みず", "mizu"),
    Question("ぎゃ", "gya"),
    Question("ひょ", "hyo"),
    Question("ちゅ", "chu"),
  ];

  final TextEditingController _controller = TextEditingController();

  Set<Question> shownQuestions = {};

  late Question leftCard;
  late Question centerCard;
  late Question rightCard;

  final bool _isWrongAnswer = false;

  late AnimationController _animationController;
  late Animation<double> _leftCardLeftPosition;
  late Animation<double> _centerCardLeftPosition;
  late Animation<double> _leftCardOpacity;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _initCards();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _leftCardLeftPosition = Tween<double>(begin: 80, end: -30).animate(_animationController);
    _centerCardLeftPosition = Tween<double>(begin: -30, end: 80).animate(_animationController);
    _leftCardOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _updateCardsAfterAnimation();
        _animationController.reset();
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  void _initCards() {
    _questions.shuffle();
    leftCard = _questions[0];
    centerCard = _questions[1];
    rightCard = _questions[2];
    shownQuestions.addAll([leftCard, centerCard, rightCard]);
  }

  void _updateCardsAfterAnimation() {
    setState(() {
      leftCard = centerCard;
      centerCard = rightCard;
      List<Question> remaining = _questions.where((q) => !shownQuestions.contains(q)).toList();

      if (remaining.isNotEmpty) {
        rightCard = remaining[Random().nextInt(remaining.length)];
        shownQuestions.add(rightCard);
      }
      _controller.clear();
    });
  }

  void _onRightCardTap() {
    if (_isAnimating) return;

    if (_controller.text.trim().toLowerCase() == centerCard.answer.toLowerCase()) {
      setState(() {
        _isAnimating = true;
      });
      _animationController.forward();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Incorrect, try again!"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
  }

  Widget _buildCard(Question q, Color color, {bool isCenter = false}) {
    final cardColor = isCenter && _isWrongAnswer ? Colors.red : color;

    return Container(
      width: 100,
      height: 140,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(q.text, style: TextStyle(fontSize: 32, color: Colors.white)),
          if (isCenter) ...[
            SizedBox(height: 10),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 160,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Positioned(
                    right: _leftCardLeftPosition.value,
                    top: 10,
                    child: Opacity(
                      opacity: _leftCardOpacity.value,
                      child: Container(
                        width: 80,
                        height: 112,
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(leftCard.text, style: TextStyle(fontSize: 26, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 80),
                    _buildCard(centerCard, Colors.blue, isCenter: true),
                  ],
                ),
              ),
              Positioned(
                left: -30,
                top: 10,
                child: GestureDetector(
                  onTap: _onRightCardTap,
                  child: Container(
                    width: 70,
                    height: 98,
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(rightCard.text, style: TextStyle(fontSize: 22, color: Colors.white)),
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

class Question {
  final String text;
  final String answer;

  Question(this.text, this.answer);
}
