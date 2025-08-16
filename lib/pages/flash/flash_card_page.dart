import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/flash/flash_card_detail.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

class FlashCardPage extends StatefulWidget {
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
    String jsonString = await rootBundle.loadString(
      'assets/json/flash_globalList.json',
    );
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
        centerTitle: true,
      ),
      body:
          _flashItems.isEmpty
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                ),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListView.builder(
                  itemCount: _flashItems.length,
                  itemBuilder: (context, index) {
                    final item = _flashItems[index];
                    final progress = item['progress'] ?? 0;
                    final total = item['words'] ?? 1;
                    final progressPercentage = (progress / total * 100).round();

                    return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [const Color.fromARGB(255, 255, 193, 245), const Color.fromARGB(255, 193, 237, 255)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              openFlashCard(
                                context,
                                index + 1,
                                item['title'].toString(),
                                item['progress'],
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          image: DecorationImage(
                                            image: AssetImage(
                                              item['image'] ??
                                                  'assets/kj.png',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ).animate().scale(
                                        duration: 500.ms,
                                        delay: (index * 100).ms,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['title'].toString(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2C3E50),
                                              ),
                                            ).animate().fadeIn(
                                              duration: 600.ms,
                                              delay: (index * 100 + 200).ms,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${item['words']} words',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ).animate().fadeIn(
                                              duration: 600.ms,
                                              delay: (index * 100 + 300).ms,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Progress',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ).animate().fadeIn(
                                        duration: 600.ms,
                                        delay: (index * 100 + 400).ms,
                                      ),
                                      Text(
                                        '$progress/$total',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF3498DB),
                                        ),
                                      ).animate().fadeIn(
                                        duration: 600.ms,
                                        delay: (index * 100 + 400).ms,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: progress / total,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF3498DB),
                                          ),
                                      minHeight: 8,
                                    ).animate().scaleX(
                                      duration: 800.ms,
                                      delay: (index * 100 + 500).ms,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$progressPercentage% Complete',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ).animate().fadeIn(
                                    duration: 600.ms,
                                    delay: (index * 100 + 600).ms,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: (index * 100).ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 600.ms,
                          delay: (index * 100).ms,
                        );
                  },
                ),
              ),
    );
  }

  void savedProgress(String title, int progress) {
    _progressBox.put(title, progress);
  }

  void openFlashCard(BuildContext context, index, title, progress) async {
    Logger().d("index no: $index"); 
    final updatedProgressMap = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => FlashCardDetailPage(
              id: index,
              title: title,
              progress: progress,
            ),
      ),
    );

    if (updatedProgressMap != null) {
      setState(() {
        final index = _flashItems.indexWhere(
          (quiz) => quiz['title'] == updatedProgressMap['title'],
        );
        if (index != -1) {
          final updatedProgress = updatedProgressMap['progress'] as int;
          _flashItems[index]['progress'] = updatedProgress;
          savedProgress(updatedProgressMap['title'], updatedProgress);
        }
      });
    }
  }
}
