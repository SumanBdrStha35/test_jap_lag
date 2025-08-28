import 'package:flutter/material.dart';

class LessonOnePage extends StatefulWidget {
  final List? lessonData;
  const LessonOnePage({super.key, this.lessonData});
  @override
  _LessonOnePageState createState() => _LessonOnePageState();
}

class _LessonOnePageState extends State<LessonOnePage> {
  // List<dynamic> lessonData = [];

  @override
  void initState() {
    super.initState();
    // _loadData();
  }

  // Future<void> _loadData() async {
  //   final String lessonJson = await DefaultAssetBundle.of(
  //     context,
  //   ).loadString('assets/json/gram_less${widget.numb}.json');

  //   final jsonString = await rootBundle.loadString(
  //     'assets/json/gram_less${widget.numb}.json',
  //   );
  //   lessonData = json.decode(jsonString);
  // }

  @override
  Widget build(BuildContext context) {
    final List lessonData = widget.lessonData ?? [];

    return Scaffold(
      appBar: AppBar(title: Text("Lesson 1: Grammar")),
      body: ListView.builder(
        itemCount: lessonData.length,
        itemBuilder: (context, index) {
          var item = lessonData[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["title"] ?? "",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (item["explanation"] != null)
                    Text(item["explanation"], style: TextStyle(fontSize: 16)),
                  if (item["example"] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["example"]["japanese"],
                          style: TextStyle(fontSize: 18, color: Colors.indigo),
                        ),
                        Text(item["example"]["english"]),
                      ],
                    ),
                  if (item["examples"] != null)
                    ...item["examples"].map<Widget>(
                      (ex) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ex["japanese"],
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.indigo,
                            ),
                          ),
                          Text(ex["english"]),
                        ],
                      ),
                    ),
                  if (item["points"] != null)
                    ...item["points"].map<Widget>(
                      (p) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p["subpoint"] != null)
                            Text(
                              p["subpoint"],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          if (p["explanation"] != null) Text(p["explanation"]),
                          if (p["example"] != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p["example"]["japanese"],
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.indigo,
                                  ),
                                ),
                                Text(p["example"]["english"]),
                              ],
                            ),
                          if (p["examples"] != null)
                            ...p["examples"].map<Widget>(
                              (ex) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex["japanese"],
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  Text(ex["english"]),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
