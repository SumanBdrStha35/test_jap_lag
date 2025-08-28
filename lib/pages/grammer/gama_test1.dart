import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/grammer/gama_testg.dart';
import 'package:flutter_app/pages/grammer/gama_testq.dart';

class LessonOneHome extends StatefulWidget {
  final String? title;

  const LessonOneHome({super.key, this.title});
  @override
  _LessonOneHomeState createState() => _LessonOneHomeState();
}

class _LessonOneHomeState extends State<LessonOneHome> {
  late final List<dynamic> lessonData;
  @override
  initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // Load your lesson data here if needed
    final int lessonNumber =
        widget.title != null ? int.parse(widget.title!) : 1;
    final jsonString = await rootBundle.loadString(
      'assets/json/gram_less$lessonNumber.json',
    );
    lessonData = json.decode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lesson 1")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("📘 Study Grammar"),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonOnePage(lessonData: lessonData),
                    ),
                  ),
            ),
            ElevatedButton(
              child: Text("📝 Take Quiz"),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonOneQuiz(lessonData: lessonData),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
