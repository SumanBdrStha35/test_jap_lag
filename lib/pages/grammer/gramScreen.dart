import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GrammarScreen extends StatefulWidget {
  final String? title;

  const GrammarScreen({super.key, this.title});

  @override
  _GrammarScreenState createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  List<Map<String, dynamic>> _quizItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (widget.title != null && widget.title!.startsWith('Lesson ')) {
        final lessonNumber = widget.title!.substring(7);
        final jsonString = await rootBundle.loadString(
          'assets/json/gram_less$lessonNumber.json',
        );
        final List<dynamic> jsonResponse = json.decode(jsonString);
        setState(() {
          _quizItems = jsonResponse.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCard(dynamic item, int index) {
    return Card(
          margin: const EdgeInsets.all(12),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with animated underline
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      Container(
                            height: 2,
                            width: 60,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                          .animate(delay: (100 * index).ms)
                          .scaleX(begin: 0, end: 1, duration: 500.ms),
                    ],
                  ),

                  if (item['explanation'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        item['explanation'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                  if (item['note'] != null || item['notes'] != null)
                    Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.yellow.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['note'] ?? item['notes'],
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate(delay: (100 * index + 100).ms)
                        .fadeIn()
                        .slideX(begin: -10, end: 0),

                  if (item['example'] != null)
                    _renderExample(item['example'], index),

                  if (item['examples'] != null)
                    ...item['examples']
                        .map<Widget>((ex) => _renderExample(ex, index))
                        .toList(),

                  if (item['additionalExamples'] != null)
                    ...item['additionalExamples']
                        .map<Widget>((ex) => _renderExample(ex, index))
                        .toList(),

                  if (item['answers'] != null)
                    ...item['answers']
                        .map<Widget>((ans) => _renderExample(ans, index))
                        .toList(),

                  if (item['points'] != null)
                    ...item['points']
                        .map<Widget>((pt) => _renderPoint(pt, index))
                        .toList(),

                  if (item['dialogue'] != null)
                    ...item['dialogue']
                        .map<Widget>((d) => _renderDialogue(d, index))
                        .toList(),

                  if (item['table'] != null) _renderTable(item['table'], index),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (100 * index).ms)
        .fadeIn()
        .slideY(begin: 20, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _renderExample(dynamic example, int parentIndex) {
    if (example is Map && example.containsKey('question')) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.question_mark,
                    size: 16,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${example['question']['japanese']} — ${example['question']['english']}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            if (example['answer'] != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${example['answer']['japanese']} — ${example['answer']['english']}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ).animate(delay: (100 * parentIndex + 150).ms).fadeIn();
    } else {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.format_quote,
                size: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "${example['japanese']} — ${example['english']}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ).animate(delay: (100 * parentIndex + 150).ms).fadeIn();
    }
  }

  Widget _renderPoint(dynamic pt, int parentIndex) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pt['subpoint'] != null)
            Text(
              pt['subpoint'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          if (pt['explanation'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(pt['explanation']),
            ),
          if (pt['example'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _renderExample(pt['example'], parentIndex),
            ),
        ],
      ),
    ).animate(delay: (100 * parentIndex + 200).ms).fadeIn();
  }

  Widget _renderDialogue(dynamic d, int parentIndex) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${d['speaker']}:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(d['japanese'], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              d['english'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (100 * parentIndex + 250).ms).fadeIn();
  }

  Widget _renderTable(Map<String, dynamic> table, int parentIndex) {
    List<DataRow> rows = [];
    table.forEach((category, series) {
      rows.add(
        DataRow(
          cells: [
            DataCell(
              Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataCell(Text(series['ko_series'] ?? '-')),
            DataCell(Text(series['so_series'] ?? '-')),
            DataCell(Text(series['a_series'] ?? '-')),
            DataCell(Text(series['do_series'] ?? '-')),
          ],
        ),
      );
    });

    return Container(
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              dataRowHeight: 48,
              headingRowHeight: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              columns: [
                DataColumn(
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Text(
                      "Category",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Text(
                      "こ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Text(
                      "そ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Text(
                      "あ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Text(
                      "ど",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
              rows: rows,
            ),
          ),
        )
        .animate(delay: (100 * parentIndex + 300).ms)
        .fadeIn()
        .slideX(begin: 20, end: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Japanese Grammar'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade600, Colors.blue.shade400],
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade400,
                  ),
                ),
              )
              : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.lightBlueAccent],
                    stops: [0.1, 0.9],
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _quizItems.length,
                  itemBuilder: (context, index) {
                    return _buildCard(_quizItems[index], index);
                  },
                ),
              ),
    );
  }
}
