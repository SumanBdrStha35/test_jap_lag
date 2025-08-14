import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GrammarScreen extends StatefulWidget {
  final String? title;

  const GrammarScreen({super.key, this.title});

  @override
  _GrammarScreenState createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  List<Map<String, dynamic>> _quizItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.title != null && widget.title!.startsWith('Lesson ')) {
      // Extract lesson number from title
      final lessonNumber = widget.title!.substring(7);
      final jsonString = await rootBundle.loadString('assets/json/gram_less$lessonNumber.json');
      final List<dynamic> jsonResponse = json.decode(jsonString);
      setState(() {
        _quizItems = jsonResponse.cast<Map<String, dynamic>>();
      });
    }
  }
  
  Widget _buildCard(dynamic item) {
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['title'] ?? 'No Title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (item['explanation'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(item['explanation']),
              ),
            if (item['note'] != null)
              Text("💡 ${item['note']}"),
            if (item['notes'] != null)
              Text("💡 ${item['notes']}"),
            if (item['example'] != null)
              _renderExample(item['example']),
            if (item['examples'] != null)
              ...item['examples'].map<Widget>((ex) => _renderExample(ex)).toList(),
            if (item['additionalExamples'] != null)
              ...item['additionalExamples'].map<Widget>((ex) => _renderExample(ex)).toList(),
            if (item['answers'] != null)
              ...item['answers'].map<Widget>((ans) => _renderExample(ans)).toList(),
            if (item['points'] != null)
              ...item['points'].map<Widget>((pt) => _renderPoint(pt)).toList(),
            if (item['dialogue'] != null)
              ...item['dialogue'].map<Widget>((d) => Text("${d['speaker']}: ${d['japanese']} — ${d['english']}")).toList(),
            if (item['table'] != null)
              _renderTable(item['table']),
          ],
        ),
      ),
    );
  }

  Widget _renderExample(dynamic example) {
    if (example is Map && example.containsKey('question')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("❓ ${example['question']['japanese']} — ${example['question']['english']}"),
          if (example['answer'] != null)
            Text("🅰️ ${example['answer']['japanese']} — ${example['answer']['english']}"),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text("🈶 ${example['japanese']} — ${example['english']}"),
      );
    }
  }

  Widget _renderPoint(dynamic pt) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pt['subpoint'] != null)
            Text(pt['subpoint'], style: TextStyle(fontWeight: FontWeight.bold)),
          if (pt['explanation'] != null)
            Text(pt['explanation']),
          if (pt['example'] != null)
            _renderExample(pt['example']),
        ],
      ),
    );
  }

  Widget _renderTable(Map<String, dynamic> table) {
    List<DataRow> rows = [];
    table.forEach((category, series) {
      rows.add(DataRow(cells: [
        DataCell(Text(category)),
        DataCell(Text(series['ko_series'] ?? '')),
        DataCell(Text(series['so_series'] ?? '')),
        DataCell(Text(series['a_series'] ?? '')),
        DataCell(Text(series['do_series'] ?? '')),
      ]));
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(columns: [
        DataColumn(label: Text("Category")),
        DataColumn(label: Text("こ")),
        DataColumn(label: Text("そ")),
        DataColumn(label: Text("あ")),
        DataColumn(label: Text("ど")),
      ], rows: rows),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text('Japanese Grammar'),
      ),
      body: ListView.builder(
        itemCount: _quizItems.length,
        itemBuilder: (context, index) {
          return _buildCard(_quizItems[index]);
        },
      ),
    );
  }
}