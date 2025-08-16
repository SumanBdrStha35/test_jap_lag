import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_app/pages/kanji/kanji_lesson.dart';
import 'package:flutter_animate/flutter_animate.dart';

class KanjiSteps extends StatefulWidget {
  final String title;

  const KanjiSteps({super.key, required this.title});

  @override
  _KanjiStepsState createState() => _KanjiStepsState();
}

class _KanjiStepsState extends State<KanjiSteps> {
  List<KanjiStep> steps = [];
  bool _isLoading = true;

  Future<List<KanjiStep>> loadKanjiSteps() async {
    try {
      final jsonString = await rootBundle.loadString('assets/json/ak.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      List<KanjiStep> loadedSteps = [];
      jsonMap.forEach((key, value) {
        int id = int.tryParse(key) ?? 0;
        loadedSteps.add(KanjiStep.fromJson(id, value));
      });
      loadedSteps.sort((a, b) => a.id.compareTo(b.id));
      return loadedSteps;
    } catch (e, stacktrace) {
      print('Error loading kanji steps: $e');
      print(stacktrace);
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    loadKanjiSteps().then((loadedSteps) {
      setState(() {
        steps = loadedSteps;
        _isLoading = false;
      });
    });
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Kanji...',
            style: TextStyle(fontSize: 16, color: Colors.green.shade700),
          ).animate().fadeIn(duration: 500.ms),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.shade100,
                Colors.green.shade50,
                Colors.white,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .effect(duration: 3000.ms, curve: Curves.easeInOut)
        .animate(target: 1)
        .color(begin: Colors.green.shade100, end: Colors.green.shade200);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header with animated title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                            "Learn Kanji",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(
                            begin: -0.5,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 8),
                      Text(
                        "Master Japanese characters",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade600,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),
                ),

                // Main content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child:
                          _isLoading
                              ? _buildLoadingIndicator()
                              : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    ..._buildPatternedGrid(),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPatternedGrid() {
    List<Widget> rows = [];
    int currentIndex = 0;

    while (currentIndex < steps.length) {
      int itemsInThisRow = _getItemsForRow(
        rows.length,
        steps.length - currentIndex,
      );

      if (currentIndex + itemsInThisRow > steps.length) {
        int remaining = steps.length - currentIndex;

        if (remaining == 3) {
          rows.add(
            _buildRow(
              steps.sublist(currentIndex, currentIndex + 2),
              2,
              currentIndex,
            ),
          );
          currentIndex += 2;

          rows.add(
            _buildRow(
              steps.sublist(currentIndex, currentIndex + 1),
              1,
              currentIndex,
            ),
          );
          currentIndex += 1;
          break;
        }

        itemsInThisRow = remaining;
      }

      rows.add(
        _buildRow(
          steps.sublist(currentIndex, currentIndex + itemsInThisRow),
          itemsInThisRow,
          currentIndex,
        ),
      );

      currentIndex += itemsInThisRow;
    }

    return rows;
  }

  int _getItemsForRow(int rowIndex, int remainingItems) {
    if (rowIndex == 0) return 1;
    if (rowIndex == 1) return 2;
    if (rowIndex == steps.length - 1) {
      if (remainingItems == 3) return 2;
      if (remainingItems == 1) return 1;
      if (remainingItems == 2) return 2;
    }
    if (rowIndex % 2 == 0) return 3;
    return 2;
  }

  Widget _buildRow(List<KanjiStep> items, int itemCount, int startIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double availableWidth = constraints.maxWidth;
          double spacing = itemCount > 1 ? 12.0 : 0.0;
          double totalSpacing = spacing * (itemCount - 1);
          double itemWidth = (availableWidth - totalSpacing) / itemCount;
          itemWidth = itemWidth.clamp(80.0, 180.0);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                items.asMap().entries.map((entry) {
                  int itemIndex = entry.key;
                  KanjiStep item = entry.value;
                  int globalIndex = startIndex + itemIndex;

                  return Padding(
                    padding: EdgeInsets.only(
                      right: itemIndex < items.length - 1 ? spacing : 0,
                    ),
                    child: _buildKanjiItem(item, itemWidth, globalIndex),
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildKanjiItem(KanjiStep item, double width, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: 500.ms,
            pageBuilder:
                (_, __, ___) => KanjiLessonPage(id: item.id, name: item.name),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated circle with glow effect
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: CircleAvatar(
                  radius: _getResponsiveRadius(width),
                  backgroundColor: _getPulseColor(index),
                  backgroundImage: AssetImage(item.image),
                )
                .animate(delay: (100 * index).ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                )
                .then()
                .effect(delay: 2.seconds, duration: 3.seconds)
                .shimmer(color: Colors.green.withOpacity(0.1)),
          ),

          const SizedBox(height: 8),

          // Animated title with overflow handling
          SizedBox(
                width: width * 0.9,
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
              .animate(delay: (100 * index + 200).ms)
              .fadeIn()
              .slideY(begin: 0.5, end: 0),
        ],
      ),
    );
  }

  Color _getPulseColor(int index) {
    final colors = [
      Colors.green.shade50,
      Colors.blue.shade50,
      Colors.orange.shade50,
    ];
    return colors[index % colors.length];
  }

  double _getResponsiveRadius(double itemWidth) {
    return (itemWidth * 0.35).clamp(30.0, 55.0);
  }

  // ... (keep your existing loadKanjiSteps and _getItemsForRow methods)
}

class KanjiStep {
  final int id;
  final String name;
  final String image;
  final String description;

  KanjiStep({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
  });

  factory KanjiStep.fromJson(int id, Map<String, dynamic> json) {
    return KanjiStep(
      id: id,
      name: json['category'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
