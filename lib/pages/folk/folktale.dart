import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'folktale_detail.dart';

class FolktalePage extends StatefulWidget {
  final String title;

  const FolktalePage({super.key, required this.title});

  @override
  State<FolktalePage> createState() => _FolktaleState();
}

class _FolktaleState extends State<FolktalePage> {
  List<dynamic> folktales = [];

  @override
  void initState() {
    super.initState();
    loadFolktales();
  }

  Future<void> loadFolktales() async {
    final String jsonString = await rootBundle.loadString('assets/json/folk_1.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      folktales = jsonData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: folktales.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: folktales.length,
              itemBuilder: (context, index) {
                final folktale = folktales[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FolktaleDetailPage(),
                        settings: RouteSettings(arguments: folktale),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.green.shade800,
                            width: 8,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Image.asset(
                            folktale['image'] ?? '',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported, size: 100),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  folktale['title'] ?? 'No Title',
                                  style: const TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  folktale['description'] ?? 'No Description',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  folktale['learning_info'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 14, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
