import 'package:flutter/material.dart';

class LessonOneQuiz extends StatefulWidget {
  final List lessonData;
  const LessonOneQuiz({super.key, required this.lessonData});

  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<LessonOneQuiz> {
  int current = 0;
  int score = 0;
  String? selected;

  List<Map<String, String>> questions = [];

  @override
  void initState() {
    super.initState();
    generateQuestions();
  }

  void generateQuestions() {
    for (var item in widget.lessonData) {
      if (item["example"] != null) {
        questions.add({
          "q": item["example"]["english"],
          "a": item["example"]["japanese"],
        });
      }
      if (item["examples"] != null) {
        for (var ex in item["examples"]) {
          questions.add({"q": ex["english"], "a": ex["japanese"]});
        }
      }
      if (item["points"] != null) {
        for (var p in item["points"]) {
          if (p["example"] != null) {
            questions.add({
              "q": p["example"]["english"],
              "a": p["example"]["japanese"],
            });
          }
          if (p["examples"] != null) {
            for (var ex in p["examples"]) {
              questions.add({"q": ex["english"], "a": ex["japanese"]});
            }
          }
          if (p["dialogue"] != null) {
            for (var d in p["dialogue"]) {
              questions.add({"q": d["english"], "a": d["japanese"]});
            }
          }
        }
      }
    }
    questions.shuffle();
  }

  void nextQuestion(String answer) {
    if (answer == questions[current]["a"]) {
      score++;
    }
    if (current < questions.length - 1) {
      setState(() {
        current++;
        selected = null;
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Quiz Finished"),
          content: Text("Score: $score / ${questions.length}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var q = questions[current];

    return Scaffold(
      appBar: AppBar(title: Text("Practice Mode")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Translate into Japanese:", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(q["q"]!, style: TextStyle(fontSize: 22)),
            Spacer(),
            TextField(
              onChanged: (val) => selected = val,
              decoration: InputDecoration(
                labelText: "Type in Japanese",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selected != null) nextQuestion(selected!);
              },
              child: Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}
