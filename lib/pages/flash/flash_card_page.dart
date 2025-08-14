import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/flash/flash_card_detail.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FlashCardPage extends StatefulWidget{
  final String title;

  const FlashCardPage({super.key, required this.title});

  @override
  State<FlashCardPage> createState() => _FlashCardPageState();
  
}

class _FlashCardPageState extends State<FlashCardPage> {
  List<dynamic> _flashItems = [];
  late Box _progressBox;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    _progressBox = await Hive.openBox('flashCardProgress');
    _loadFlashData();
  }

  Future<void> _loadFlashData() async {
    String jsonString = await rootBundle.loadString('assets/json/flash_globalList.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);
    setState(() {
      _flashItems = jsonResponse;
    });
    _loadProgress();
  }

  void _loadProgress() {
    setState(() {
      for (var quiz in _flashItems) {
        final savedProgress = _progressBox.get(quiz['title']);
        if (savedProgress != null) {
          quiz['progress'] = savedProgress;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _flashItems.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _flashItems.length,
              itemBuilder: (context, index) {
                final item = _flashItems[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(item['image'] ?? 'assets/images/default.png'),
                    ),
                    title: Text(item['title'].toString()),
                    subtitle: Text(item['words'].toString()),
                    trailing: item['progress'] != null
                        ? Text('${item['progress']}/ ${item['words']}', style: TextStyle(fontWeight: FontWeight.bold))
                        : null,
                    onTap: () {
                      openFlashCard(context, item['title'].toString(), item['progress']);
                    },
                  ),
                );
              },
            ),
    );
  }

  void savedProgress(String title, int progress) {
    _progressBox.put(title, progress);
  }
  
  void openFlashCard(BuildContext context, title, progress) async{
    final updatedProgressMap = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => FlashCardDetailPage(title: title, progress: progress),
      ),
    );

    if (updatedProgressMap != null) {
      setState(() {
        final index = _flashItems.indexWhere((quiz) => quiz['title'] == updatedProgressMap['title']);
        if (index != -1) {
          final updatedProgress = updatedProgressMap['progress'] as int;
          _flashItems[index]['progress'] = updatedProgress;
          savedProgress(updatedProgressMap['title'], updatedProgress);
        }
      });
    }
  }
}