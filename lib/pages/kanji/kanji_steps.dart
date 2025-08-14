import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_app/pages/kanji/kanji_lesson.dart';

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

class KanjiSteps extends StatefulWidget {
  final String title;

  const KanjiSteps({super.key, required this.title});

  @override
  _KanjiStepsState createState() => _KanjiStepsState();
}

class _KanjiStepsState extends State<KanjiSteps> {
  List<KanjiStep> steps = [];

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
      });
    });
  }

  List<Widget> _buildPatternedGrid() {
    List<Widget> rows = [];
    int currentIndex = 0;
    
    while (currentIndex < steps.length) {
      int itemsInThisRow = _getItemsForRow(rows.length, steps.length - currentIndex);
      
      // Handle remainder cases
      if (currentIndex + itemsInThisRow > steps.length) {
        int remaining = steps.length - currentIndex;
        
        // Special handling for remainder of 3
        if (remaining == 3) {
          // First row with 2 items
          rows.add(_buildRow(
            steps.sublist(currentIndex, currentIndex + 2),
            2,
            currentIndex
          ));
          currentIndex += 2;
          
          // Second row with 1 item
          rows.add(_buildRow(
            steps.sublist(currentIndex, currentIndex + 1),
            1,
            currentIndex
          ));
          currentIndex += 1;
          break;
        }
        
        // For other remainders, just use what's left
        itemsInThisRow = remaining;
      }
      
      rows.add(_buildRow(
        steps.sublist(currentIndex, currentIndex + itemsInThisRow),
        itemsInThisRow,
        currentIndex
      ));
      
      currentIndex += itemsInThisRow;
      
      if (currentIndex >= steps.length) break;
    }
    
    return rows;
  }

  int _getItemsForRow(int rowIndex, int remainingItems) {
    if (rowIndex == 0) return 1;  // First row: 1 item
    if (rowIndex == 1) return 2;  // Second row: 2 items
    //check if last row
    if(rowIndex == steps.length - 1){
      if(remainingItems == 3) return 2;
      if(remainingItems == 1) return 1;
      if(remainingItems == 2) return 2;
    }
    if (rowIndex % 2 == 0) {  // Even rows: 3 items
      return 3;
    } else {  // Odd rows: 2 items
      return 2;
    }  
  }

  Widget _buildRow(List<KanjiStep> items, int itemCount, int startIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate available width accounting for padding between items
          double availableWidth = constraints.maxWidth;
          double spacing = itemCount > 1 ? 12.0 : 0.0;
          double totalSpacing = spacing * (itemCount - 1);
          double itemWidth = (availableWidth - totalSpacing) / itemCount;
          
          // Ensure minimum width and maximum constraints
          itemWidth = itemWidth.clamp(80.0, 180.0);
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items.asMap().entries.map((entry) {
              int itemIndex = entry.key;
              KanjiStep item = entry.value;
              
              return Padding(
                padding: EdgeInsets.only(right: itemIndex < items.length - 1 ? spacing : 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KanjiLessonPage(
                          id: item.id,
                          name: item.name
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: itemWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: _getResponsiveRadius(itemWidth),
                          backgroundColor: Colors.green.shade50,
                          backgroundImage: AssetImage(item.image),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.name,
                          style: const TextStyle(fontSize: 13),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  double _getResponsiveRadius(double itemWidth) {
    // Responsive radius based on available width
    return (itemWidth * 0.35).clamp(30.0, 55.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Learn Kanji",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: _buildPatternedGrid(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
