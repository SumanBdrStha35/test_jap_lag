import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FlashCardDetailPage extends StatefulWidget {
  final String? title;
  final int? progress;

  const FlashCardDetailPage({super.key, this.title, this.progress});

  @override
  _FlashCardDetailPageState createState() => _FlashCardDetailPageState();
}

class _FlashCardDetailPageState extends State<FlashCardDetailPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _items = [];
  int _currentIndex = 0;
  bool showDetails = false;
  int correctAnsCount = 0;
  int completedCount = 0;
  Map<String, dynamic>? get item => _items.isNotEmpty ? _items[_currentIndex] : null;

  Future<void> _loadData() async {
    String jsonString;
    if (widget.title == "Seasons") {
      jsonString = await rootBundle.loadString('assets/json/flash_global1.json');
    }
    else if (widget.title == "N5 Vocab") {
      jsonString = await rootBundle.loadString('assets/json/flash_global2.json');
    }
    else if (widget.title == "N5 Vocabularies (Noun)") {
      jsonString = await rootBundle.loadString('assets/json/flash_global3.json');
    }
    else {
      jsonString = await rootBundle.loadString('assets/json/flash_global1.json');
    }
    final List<dynamic> jsonResponse = json.decode(jsonString);
    _shuffleItems();
    setState(() {
      _items = jsonResponse.cast<Map<String, dynamic>>();
      completedCount = widget.progress ?? 0;
    });
  }

  void _shuffleItems() {
    _items.shuffle(Random());
    _currentIndex = 0;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _nextItem() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _items.length;
      showDetails = false;
    });
  }

  void _previousItem() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = (_currentIndex - 1) % _items.length;
      if (_currentIndex < 0) _currentIndex = _items.length - 1;
      showDetails = false;
    });
  }

   void answerQuestion(bool isCorrect) {
    HapticFeedback.heavyImpact();
    setState(() {
      if (isCorrect) {
        correctAnsCount++;
      }
      showDetails = true;
    });
    
    // Auto-advance after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextItem();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _items[_currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Flash Card Detail'),
        ),
        body: Center(
          child: Text('No data found'),
        ),
      );
    }
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'Flash Card Detail'),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_currentIndex + 1}/${_items.length}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54,),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () async {
                          final FlutterTts flutterTts = FlutterTts();
                          await flutterTts.speak(currentCard['kana'] ?? '');
                        },
                      ),
                    ],
                  ),
                ),
                
                // Main flashcard
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        _previousItem();
                      } else if (details.primaryVelocity! < 0) {
                        _nextItem();
                      }
                    },
                    child: Center(
                      child: Container(
                        width: screenWidth * 0.9,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(int.parse(currentCard["cardColor"].toString().replaceFirst('#', '0xff'))).withOpacity(0.9),
                                  Color(int.parse(currentCard["cardColor"].toString().replaceFirst('#', '0xff'))).withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Text(
                                currentCard['kanji'] ?? '',
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 6,
                                      color: Colors.black26,
                                      offset: Offset(2, 2),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),                          
                            // Kana (phonetic)
                            Text(
                              currentCard['kana'] ?? '',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white.withOpacity(0.9),
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(1, 1),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Example (shown only when details are visible)
                            if (showDetails) ...[
                              // Meaning
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  currentCard['meaning'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Example:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      currentCard['example'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            
                            // View Details button
                            const Spacer(),
                            if (!showDetails) ...[
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    showDetails = true;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('View Detail',
                                      style: TextStyle(
                                        shadows: [
                                          Shadow(
                                            blurRadius: 4,
                                            color: Colors.black26,
                                            offset: Offset(1, 1),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(Icons.keyboard_arrow_down, size: 20),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Bottom navigation and answer buttons
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left arrow
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          iconSize: 24,
                          color: Colors.black54,
                          onPressed: _previousItem,
                        ),
                      ),                    
                      // Wrong/Right buttons (only visible when details are shown)
                      if (showDetails) ...[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          onPressed: () {
                            answerQuestion(false);
                          },
                          child: const Text('Wrong', 
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          onPressed: () {
                            answerQuestion(true);
                          },
                          child: const Text('Right', 
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      // Right arrow
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          iconSize: 24,
                          color: Colors.black54,
                          onPressed: _nextItem,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    Navigator.pop(
      context, 
      {
        'title': widget.title, 
        'progress': correctAnsCount
      }
    );
    return true;

  }
}
