import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FlashCardDetailPage extends StatefulWidget {
  final int? id;
  final String? title;
  final int? progress;

  const FlashCardDetailPage({super.key, this.id, this.title, this.progress});

  @override
  _FlashCardDetailPageState createState() => _FlashCardDetailPageState();
}

class _FlashCardDetailPageState extends State<FlashCardDetailPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _items = [];
  int _currentIndex = 0;
  bool showDetails = false;
  int correctAnsCount = 0;
  int completedCount = 0;
  int streakCount = 0;
  late ConfettiController _confettiController;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFrontVisible = true;
  final List<Color> _gradientColors = [
    const Color.fromARGB(255, 127, 255, 68),
    const Color.fromARGB(255, 36, 167, 255),
    const Color.fromARGB(255, 252, 41, 206),
  ];
  late AnimationController _bgController;
  late Animation<Color?> _bgAnimation;
  final Random _random = Random();
  final List<Offset> _particles = [];
  Timer? _particleTimer;

  Map<String, dynamic>? get item =>
      _items.isNotEmpty ? _items[_currentIndex] : null;

  @override
  void initState() {
    super.initState();
    _loadData();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
    _flipController = AnimationController(
      vsync: this,
      duration: 500.milliseconds,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _bgController = AnimationController(vsync: this, duration: 10.seconds)
      ..repeat(reverse: true);
    _bgAnimation = ColorTween(
      begin: _gradientColors[0],
      end: _gradientColors[2],
    ).animate(_bgController);
    _initParticles();
  }

  void _initParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(
        Offset(_random.nextDouble() * 1000, _random.nextDouble() * 1000),
      );
    }
    _particleTimer = Timer.periodic(100.milliseconds, (timer) {
      setState(() {
        for (int i = 0; i < _particles.length; i++) {
          _particles[i] = Offset(
            _particles[i].dx + (_random.nextDouble() * 2 - 1),
            _particles[i].dy + (_random.nextDouble() * 2 - 1),
          );
        }
      });
    });
  }

  Future<void> _loadData() async {
    String jsonString = await rootBundle.loadString(
      'assets/json/flash_global${widget.id}.json',
    );
    final List<dynamic> jsonResponse = json.decode(jsonString);
    setState(() {
      _items = jsonResponse.cast<Map<String, dynamic>>();
      _shuffleItems();
      completedCount = widget.progress ?? 0;
    });
  }

  void _shuffleItems() {
    _items.shuffle(Random());
    _currentIndex = 0;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _flipController.dispose();
    _bgController.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }

  void _nextItem() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _items.length;
      showDetails = false;
      _isFrontVisible = true;
      _flipController.reset();
    });
  }

  void _previousItem() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = (_currentIndex - 1) % _items.length;
      if (_currentIndex < 0) _currentIndex = _items.length - 1;
      showDetails = false;
      _isFrontVisible = true;
      _flipController.reset();
    });
  }

  void answerQuestion(bool isCorrect) {
    HapticFeedback.heavyImpact();
    setState(() {
      if (isCorrect) {
        correctAnsCount++;
        streakCount++;
        if (streakCount % 5 == 0) {
          _confettiController.play();
        }
      } else {
        streakCount = 0;
      }
      showDetails = true;
    });

    Future.delayed(1.5.seconds, () {
      if (mounted) {
        _nextItem();
      }
    });
  }

  void _flipCard() {
    if (_flipController.isCompleted || _flipController.isDismissed) {
      _isFrontVisible ? _flipController.forward() : _flipController.reverse();
      _isFrontVisible = !_isFrontVisible;
    }
  }

  Widget _buildParticles() {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(painter: ParticlePainter(_particles)),
      ),
    );
  }

  Widget _buildCardFront(Map<String, dynamic> currentCard) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(
              int.parse(
                currentCard["cardColor"].toString().replaceFirst('#', '0xff'),
              ),
            ).withOpacity(0.9),
            Color(
              int.parse(
                currentCard["cardColor"].toString().replaceFirst('#', '0xff'),
              ),
            ).withOpacity(0.7),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          IconButton(
            icon: const Icon(
              Icons.rotate_90_degrees_ccw,
              color: Colors.white70,
            ),
            onPressed: _flipCard,
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(Map<String, dynamic> currentCard) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(
              int.parse(
                currentCard["cardColor"].toString().replaceFirst('#', '0xff'),
              ),
            ).withOpacity(0.7),
            Color(
              int.parse(
                currentCard["cardColor"].toString().replaceFirst('#', '0xff'),
              ),
            ).withOpacity(0.9),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Meaning
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
            // Example
            Container(
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
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(
                Icons.rotate_90_degrees_ccw,
                color: Colors.white70,
              ),
              onPressed: _flipCard,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'Flash Card Detail')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentCard = _items[_currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'Flash Card Detail'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: streakCount > 0 ? Colors.orange : Colors.grey,
                  ),
                  Text(
                    '$streakCount',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 0, 0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: _bgAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // Animated Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _bgAnimation.value!,
                        _bgAnimation.value!.withOpacity(0.7),
                        _bgAnimation.value!.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),

                // Particles
                _buildParticles(),

                // Content
                SafeArea(
                  child: Column(
                    children: [
                      // Progress indicators
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Circular progress
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: Stack(
                                children: [
                                  CircularProgressIndicator(
                                    value: _currentIndex / _items.length,
                                    backgroundColor: Colors.white24,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      '${_currentIndex + 1}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // TTS Button
                            IconButton(
                              icon: const Icon(
                                Icons.volume_up,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                final FlutterTts flutterTts = FlutterTts();
                                await flutterTts.speak(
                                  currentCard['kana'] ?? '',
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Main flashcard with flip animation
                      Expanded(
                        child: GestureDetector(
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity! > 0) {
                              _previousItem();
                            } else if (details.primaryVelocity! < 0) {
                              _nextItem();
                            }
                          },
                          onVerticalDragEnd: (details) {
                            if (details.primaryVelocity! < 0) {
                              _flipCard();
                            }
                          },
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: 300.milliseconds,
                              child: AnimatedBuilder(
                                animation: _flipAnimation,
                                builder: (context, child) {
                                  final angle = _flipAnimation.value * pi;
                                  final transform =
                                      Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(angle);

                                  return Transform(
                                    transform: transform,
                                    alignment: Alignment.center,
                                    child:
                                        angle < pi / 2 || angle > 3 * pi / 2
                                            ? _buildCardFront(currentCard)
                                            : Transform(
                                              transform:
                                                  Matrix4.identity()
                                                    ..rotateY(pi),
                                              alignment: Alignment.center,
                                              child: _buildCardBack(
                                                currentCard,
                                              ),
                                            ),
                                  );
                                },
                              ),
                            ).animate().shakeX(
                              delay: 1.seconds,
                              duration: 500.milliseconds,
                            ),
                          ),
                        ),
                      ),

                      // Answer buttons (only shown when card is flipped)
                      if (!_isFrontVisible)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[400],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                onPressed: () => answerQuestion(false),
                                child: const Text(
                                  'Wrong',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[400],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                onPressed: () => answerQuestion(true),
                                child: const Text(
                                  'Right',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Navigation buttons
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.skip_previous,
                                color: Colors.white,
                              ),
                              iconSize: 32,
                              onPressed: _previousItem,
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: Icon(Icons.skip_next, color: Colors.white),
                              iconSize: 32,
                              onPressed: _nextItem,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Confetti for achievements
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
                    createParticlePath: drawStar,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    Navigator.pop(context, {
      'title': widget.title,
      'progress': correctAnsCount,
      'streak': streakCount,
    });
    return true;
  }

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Offset> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..style = PaintingStyle.fill;

    for (final particle in particles) {
      canvas.drawCircle(particle, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
