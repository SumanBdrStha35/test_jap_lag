import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';

class GrammarScreen extends StatefulWidget {
  final String? title;

  const GrammarScreen({super.key, this.title});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadData();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("ja-JP");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> _speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print("Error in TTS speak: $e");
    }
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
          _items = jsonResponse.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return GrammarCard(item: _items[index], index: index);
                },
              ),
    );
  }
}

/// Grammar Card
class GrammarCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;

  const GrammarCard({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              item['title'] ?? 'No Title',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            Container(
              height: 2,
              width: 60,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ).animate(delay: (100 * index).ms).scaleX(begin: 0, end: 1),

            if (item['explanation'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(item['explanation']),
              ),

            if (item['subsections'] != null)
              ...item['subsections']
                  .cast<Map<String, dynamic>>()
                  .map((sub) => SubsectionsTile(subsection: sub))
                  .toList(),

            if (item['sections'] != null)
              ...item['sections']
                  .cast<Map<String, dynamic>>()
                  .map((sec) => SectionTile(section: sec))
                  .toList(),

            if (item['subpoints'] != null)
              ...item['subpoints']
                  .cast<Map<String, dynamic>>()
                  .map((sp) => SubpointTile(sp: sp))
                  .toList(),

            if (item['notes'] != null && item['notes'] is List<dynamic>)
              ...item['notes'].map((n) => NoteBox(text: n.toString())).toList(),

            if (item['note'] != null) NoteBox(text: item['note']),

            if (item['example'] != null) _renderExample(item['example']),
            if (item['examples'] != null)
              ...item['examples']
                  .cast<Map<String, dynamic>>()
                  .map((ex) => _renderExample(ex))
                  .toList(),

            if (item['uses'] != null)
              ...item['uses']
                  .cast<Map<String, dynamic>>()
                  .map((u) => UseTile(use: u))
                  .toList(),

            if (item['table'] != null) TableTile(table: item['table']),

            if (item['points'] != null)
              ...item['points']
                  .cast<Map<String, dynamic>>()
                  .map((pt) => PointTile(point: pt))
                  .toList(),

            if (item['dialogue'] != null)
              ...item['dialogue']
                  .cast<Map<String, dynamic>>()
                  .map((d) => DialogueTile(dialogue: d))
                  .toList(),
          ],
        ),
      ),
    ).animate(delay: (100 * index).ms).fadeIn().slideY(begin: 20, end: 0);
  }

  Widget _renderExample(dynamic example) {
    if (example is Map && example['dialogue'] != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (example['japanese'] != null || example['english'] != null)
            ExampleTile(example: Map<String, dynamic>.from(example)),
          ...example['dialogue']
              .cast<Map<String, dynamic>>()
              .map((d) => DialogueTile(dialogue: d))
              .toList(),
        ],
      );
    }

    // Multiple answers
    if (example is Map && example['answers'] != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExampleTile(example: Map<String, dynamic>.from(example)),
          ...example['answers']
              .cast<Map<String, dynamic>>()
              .map((ans) => AnswerTile(answer: ans))
              .toList(),
        ],
      );
    }

    if (example is Map && example['answer'] != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (example['japanese'] != null || example['english'] != null)
            // ExampleTile(example: Map<String, dynamic>.from(example)),
            ExampleTile(
              example: {
                'japanese': example['japanese'],
                'english': example['english'],
              },
            ),
          // AnswerTile(answer: example['answer']),
          AnswerTile(answer: Map<String, dynamic>.from(example['answer'])),
        ],
      );
    }

    // Polite vs Plain
    if (example is Map &&
        example['polite'] != null &&
        example['plain'] != null) {
      return PolitePlainTile(example: Map<String, dynamic>.from(example));
    }

    // Conjugation group
    if (example is Map && example.containsKey('group')) {
      final g = example['group'] ?? 'Other';
      return ConjugationGroup(
        groupName: g,
        verbs: [Map<String, dynamic>.from(example)],
      );
    }

    // Note-only example
    if (example is Map && example['note'] != null) {
      return NoteBox(text: example['note']);
    }

    // default
    return ExampleTile(example: Map<String, dynamic>.from(example));
  }
}

class SubsectionsTile extends StatelessWidget {
  final Map<String, dynamic> subsection;
  const SubsectionsTile({super.key, required this.subsection});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subsection['subtitle'] != null)
            Text(
              subsection['subtitle'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal,
                fontSize: 16,
              ),
            ),
          if (subsection['explanation'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(subsection['explanation']),
            ),
          if (subsection['examples'] != null)
            ...subsection['examples']
                .cast<Map<String, dynamic>>()
                .map((ex) => ExampleTile(example: ex))
                .toList(),
        ],
      ),
    );
  }
}

/// Section Widget (for Lesson 20)
class SectionTile extends StatelessWidget {
  final Map<String, dynamic> section;
  const SectionTile({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section['subtitle'] != null)
            Text(
              section['subtitle'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
                fontSize: 16,
              ),
            ),
          if (section['explanation'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(section['explanation']),
            ),
          if (section['examples'] != null)
            ...section['examples']
                .cast<Map<String, dynamic>>()
                .map((ex) => ExampleTile(example: ex))
                .toList(),
        ],
      ),
    );
  }
}

/// Polite vs Plain Example Widget
class PolitePlainTile extends StatelessWidget {
  final Map<String, dynamic> example;
  const PolitePlainTile({super.key, required this.example});

  @override
  Widget build(BuildContext context) {
    final polite = example['polite'] ?? '';
    final plain = example['plain'] ?? '';
    final english = example['english'] ?? '';

    return Container(
      margin: const EdgeInsets.only(top: 8),
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
              Expanded(
                child: Text(
                  "Polite: $polite",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Text(
                  "Plain: $plain",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            english,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Subpoint Widget
class SubpointTile extends StatelessWidget {
  final Map<String, dynamic> sp;
  const SubpointTile({super.key, required this.sp});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sp['title'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          if (sp['examples'] != null)
            ...sp['examples']
                .cast<Map<String, dynamic>>()
                .map((ex) => ExampleTile(example: ex))
                .toList(),
          SizedBox( height: 8, ),
          if (sp['note'] != null) NoteBox(text: sp['note']),
        ],
      ),
    );
  }
}

/// Conjugation Group Widget (for Lesson 17 verbs)
class ConjugationGroup extends StatelessWidget {
  final String groupName;
  final List<Map<String, dynamic>> verbs;

  const ConjugationGroup({
    super.key,
    required this.groupName,
    required this.verbs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...verbs.map((v) {
            // final dict = v['dictionary'] ?? '';
            // final masu = v['masu'] ?? '';
            final nai = v['japanese'] ?? '';
            final en = v['english'] ?? '';
            return Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Text(
                "$nai — $en",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

/// Note Widget
class NoteBox extends StatelessWidget {
  final String text;
  const NoteBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.yellow.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.orange.shade800,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example Widget
class ExampleTile extends StatelessWidget {
  final Map<String, dynamic> example;
  const ExampleTile({super.key, required this.example});

  @override
  Widget build(BuildContext context) {
    final japaneseText = example['japanese']?.toString() ?? '';
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "${example['japanese']} — ${example['english'] ?? ''}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              if (japaneseText.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 20),
                  onPressed: () {
                    final grammarScreenState = context.findAncestorStateOfType<_GrammarScreenState>();
                    grammarScreenState?._speak(japaneseText);
                  },
                ),
            ],
          ),
          if (example['answer'] != null) AnswerTile(answer: example['answer']),
          if (example['answers'] != null)
            ...example['answers']
                .cast<Map<String, dynamic>>()
                .map((ans) => AnswerTile(answer: ans))
                .toList(),
        ],
      ),
    );
  }
}

/// Answer Widget
class AnswerTile extends StatelessWidget {
  final Map<String, dynamic> answer;
  const AnswerTile({super.key, required this.answer});

  @override
  Widget build(BuildContext context) {
    final jp = answer['japanese']?.toString().split(RegExp(r' ?/ ?|\n')) ?? [];
    final en = answer['english']?.toString().split(RegExp(r' ?/ ?|\n')) ?? [];

    return Container(
      margin: const EdgeInsets.only(left: 24, top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(jp.length, (i) {
          final japaneseText = jp[i].trim();
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${jp[i]} — ${i < en.length ? en[i] : ''}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (japaneseText.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 16),
                    onPressed: () {
                      final grammarScreenState = context.findAncestorStateOfType<_GrammarScreenState>();
                      grammarScreenState?._speak(japaneseText);
                    },
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Use Widget
class UseTile extends StatelessWidget {
  final Map<String, dynamic> use;
  const UseTile({super.key, required this.use});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            use['type'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          if (use['example'] != null) ExampleTile(example: use['example']),
          if (use['examples'] != null)
            ...use['examples']
                .cast<Map<String, dynamic>>()
                .map((ex) => ExampleTile(example: ex))
                .toList(),
        ],
      ),
    );
  }
}

/// Table Widget
class TableTile extends StatelessWidget {
  final Map<String, dynamic> table;
  const TableTile({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    final headers = table.keys.toList();
    final rows = <List<String>>[];

    final length = (table[headers.first] as List).length;
    for (int i = 0; i < length; i++) {
      rows.add(headers.map<String>((h) => table[h]?[i] ?? '').toList());
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        border: TableBorder.all(color: Colors.grey.shade300),
        columns:
            headers
                .map(
                  (h) => DataColumn(
                    label: Text(
                      h,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                )
                .toList(),
        rows:
            rows
                .map(
                  (r) => DataRow(
                    cells: r.map((cell) => DataCell(Text(cell))).toList(),
                  ),
                )
                .toList(),
      ),
    );
  }
}

/// Point Widget
class PointTile extends StatelessWidget {
  final Map<String, dynamic> point;
  const PointTile({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (point['subpoint'] != null)
            Text(
              point['subpoint'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          if (point['explanation'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(point['explanation']),
            ),
          if (point['example'] != null) ExampleTile(example: point['example']),
          if (point['examples'] != null)
            ...point['examples']
                .cast<Map<String, dynamic>>()
                .map((ex) => ExampleTile(example: ex))
                .toList(),

          if (point['dialogue'] != null)
            ...point['dialogue']
                .cast<Map<String, dynamic>>()
                .map((d) => DialogueTile(dialogue: d))
                .toList(),
        ],
      ),
    );
  }
}

/// Dialogue Widget
class DialogueTile extends StatelessWidget {
  final Map<String, dynamic> dialogue;
  const DialogueTile({super.key, required this.dialogue});

  @override
  Widget build(BuildContext context) {
    final japaneseText = dialogue['japanese']?.toString() ?? '';
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dialogue['speaker'] != null)
            Text(
              "${dialogue['speaker']}:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text(dialogue['japanese'], style: const TextStyle(fontSize: 16)),
              ),
              if (japaneseText.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 16),
                  onPressed: () {
                    final grammarScreenState = context.findAncestorStateOfType<_GrammarScreenState>();
                    grammarScreenState?._speak(japaneseText);
                  },
                ),
            ],
          ),
          if (dialogue['english'] != null)
            Text(
              dialogue['english'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
