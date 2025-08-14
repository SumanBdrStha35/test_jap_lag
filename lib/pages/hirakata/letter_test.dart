import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/hirakata/kana_quize.dart';

class LetterTest extends StatefulWidget {
  final String title;

  const LetterTest({
    super.key,
    required this.title,
  });

  @override
  State<LetterTest> createState() => _LetterTestState();
}

class _LetterTestState extends State<LetterTest> {
  late Map<String, String> ganaList = {};
  late Map<String, String> dakutenList = {};
  late Map<String, String> combinationList = {};
  late Map<String, String> allKanaList = {};
  
  @override
  void initState() {
    super.initState();
    loadData(); 
  }

  Future<void> loadData() async {
    try {
      if (widget.title == "Hiragana") {
        final jsonString = await rootBundle.loadString('assets/data/hiragana_data.json');
        final jsonData = json.decode(jsonString);
        
        setState(() {
          ganaList = Map<String, String>.from(jsonData['hiraganaList']);
          dakutenList = Map<String, String>.from(jsonData['dakutenList']);
          combinationList = Map<String, String>.from(jsonData['combinationList']);
          
          // Merge all lists into one
          allKanaList = {};
          allKanaList.addAll(ganaList);
          allKanaList.addAll(dakutenList);
          allKanaList.addAll(combinationList);
        });
      } else if (widget.title == "Katakana") {
        final jsonString = await rootBundle.loadString('assets/data/katakana_data.json');
        final jsonData = json.decode(jsonString);
        
        setState(() {
          ganaList = Map<String, String>.from(jsonData['katakanaList']);
          dakutenList = Map<String, String>.from(jsonData['dakutenList']);
          combinationList = Map<String, String>.from(jsonData['combinationList']);
          
          // Merge all lists into one
          allKanaList = {};
          allKanaList.addAll(ganaList);
          allKanaList.addAll(dakutenList);
          allKanaList.addAll(combinationList);
        });
      }
    } catch (e) {
      print("Error loading data: $e");
      setState(() {
        ganaList = {};
        dakutenList = {};
        combinationList = {};
        allKanaList = {};
      });
    }
  }

  // Sample data for 4 cards
  List<Map<String, dynamic>> get cardData {
    return [
      {
        'title': widget.title == "Hiragana" ? 'Hiragana' : 'Katakana',
        'subtitle': 'Basic',
        'icon': Icons.text_fields,
        'color': Colors.blue,
        'count': ganaList.length,
        'data': ganaList,
        "progress": 30
      },
      {
        'title': 'Dakuon',
        'subtitle': 'Dakuon and Handakuon',
        'icon': Icons.text_format,
        'color': Colors.red,
        'count': dakutenList.length,
        'data': dakutenList,
        "progress": 20
      },
      {
        'title': 'Contracted',
        'subtitle': 'Contracted Sounds',
        'icon': Icons.volume_up,
        'color': Colors.green,
        'count': combinationList.length,
        'data': combinationList,
        "progress": 10
      },
      {
        'title': 'All Characters',
        'subtitle': 'Complete Set',
        'icon': Icons.all_inclusive,
        'color': Colors.orange,
        'count': allKanaList.length,
        'data': allKanaList,
        "progress": 70
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Select Test Type',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: cardData.map((card) => _buildTestCard(card)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(Map<String, dynamic> card) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle card tap
          _onCardTap(card['title'], card['data'], card['count']);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                card['color'].withOpacity(0.8),
                card['color'].withOpacity(0.6),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                card['icon'],
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                card['title'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                card['subtitle'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${card['count']} characters',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              LinearProgressIndicator(
                value: card['progress'] / card['count'],
                minHeight: 4,
                backgroundColor: Colors.black54,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onCardTap(String title, Map<String, String> data, int count) {
    // Navigate to a new screen with the tapped card's data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KanaQuize(
          title: title,
          kanaType: data,
          maxChar: count,
        ),
      ),
    );
  }
}
