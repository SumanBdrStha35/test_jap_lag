import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';

class AppendicesPage extends StatefulWidget {
  final String fileName;
  final String pTitle;
  const AppendicesPage({
    super.key,
    required this.pTitle,
    required this.fileName,
  });

  @override
  State<AppendicesPage> createState() => _AppendicesPageState();
}

class _AppendicesPageState extends State<AppendicesPage> {
  List<Widget>? _greetings;
  List<Widget>? _originalGreetings;
  FlutterTts? _flutterTts;
  Logger logger = Logger();
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _searchController.addListener(() {
      _filterGreetings(_searchController.text);
    });
    _loadGreeting();
  }

  Future<void> _loadGreeting() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/${widget.fileName}.json',
      );
      final jsonMap = jsonDecode(jsonString);
      List<Widget> tiles = [];

      if (jsonMap.containsKey('greetings_expressions') ||
          jsonMap.containsKey('colors') ||
          jsonMap.containsKey('body_parts') ||
          jsonMap.containsKey('family')) {
        List<Map<String, dynamic>> greetings = [];
        if (jsonMap.containsKey('greetings_expressions')) {
          greetings = List<Map<String, dynamic>>.from(
            jsonMap['greetings_expressions'],
          );
        } else if (jsonMap.containsKey('colors')) {
          greetings = List<Map<String, dynamic>>.from(jsonMap['colors']);
        } else if (jsonMap.containsKey('body_parts')) {
          greetings = List<Map<String, dynamic>>.from(jsonMap['body_parts']);
        } else if (jsonMap.containsKey('family')) {
          greetings = List<Map<String, dynamic>>.from(jsonMap['family']);
        }
        tiles =
            greetings.map((greeting) {
              return ListTile(
                title: Text(greeting['name']),
                subtitle: Text(greeting['meaning']),
                trailing: IconButton(
                  icon: Icon(Icons.volume_up),
                  onPressed: () => _speak(greeting['name']),
                ),
              );
            }).toList();
      } else if (jsonMap.containsKey('Numerals')) {
        final List<Map<String, dynamic>> numbers =
            List<Map<String, dynamic>>.from(jsonMap['Numerals']);
        tiles =
            numbers.map((item) {
              return ListTile(
                title: Text(item['name']),
                subtitle: Text(item['key']),
                trailing: IconButton(
                  icon: Icon(Icons.volume_up),
                  onPressed: () => _speak(item['name']),
                ),
              );
            }).toList();
      } else {
        jsonMap.forEach((category, items) {
          // Top-level header
          tiles.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          );
          if (items is List) {
            // Direct list of items
            for (var item in items) {
              final String? name = item['name'] ?? item['word'];
              final String? meaning = item['meaning'];

              if (name != null) {
                String subtitleText = meaning ?? '';
                if (item.containsKey('ます-form')) {
                  subtitleText += '\nます-form: ${item['ます-form']}';
                  subtitleText += '\nて-form: ${item['て-form']}';
                  subtitleText += '\nDictionary: ${item['dictionary']}';
                  subtitleText += '\nない-form: ${item['ない-form']}';
                  subtitleText += '\nた-form: ${item['た-form']}';
                }
                tiles.add(
                  Card(
                    child: ListTile(
                      title: Text(name),
                      subtitle: subtitleText.isNotEmpty ? Text(subtitleText) : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _speak(name),
                      ),
                    ),
                  ),
                );
              }
            }
          } else if (items is Map) {
            // Nested subcategories (like telling time, date, period)
            items.forEach((subCategory, subItems) {
              // Sub-header
              tiles.add(
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    top: 4.0,
                    bottom: 4.0,
                  ),
                  child: Text(
                    subCategory,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              );

              if (subItems is List) {
                for (var item in subItems) {
                  final String? name = item['name'];
                  final String? meaning = item['meaning'];

                  if (name != null) {
                    tiles.add(
                      ListTile(
                        contentPadding: const EdgeInsets.only(
                          left: 32.0,
                          right: 16.0,
                        ),
                        title: Text(name),
                        subtitle: meaning != null ? Text(meaning) : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.volume_up),
                          onPressed: () => _speak(name),
                        ),
                      ),
                    );
                  }
                }
              }
            });
          }
        });
      }
      setState(() {
        _originalGreetings = tiles;
        _greetings = tiles;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      logger.d('Error loading greeting data: $e');
    }
  }

  void _filterGreetings(String query) {
    _searchQuery = query;
    if (_originalGreetings == null) return;
    if (query.isEmpty) {
      _greetings = _originalGreetings;
    } else {
      _greetings = _originalGreetings!.where((widget) {
        if (widget is ListTile) {
          final title = (widget.title as Text?)?.data ?? '';
          final subtitle = (widget.subtitle as Text?)?.data ?? '';
          return title.toLowerCase().contains(query.toLowerCase()) ||
                 subtitle.toLowerCase().contains(query.toLowerCase());
        }
        return false; // Don't include headers in search
      }).toList();
    }
    setState(() {});
  }

  void _speak(String text) async {
    if (_flutterTts == null) {
      logger.w('FlutterTts is not initialized');
      return;
    }
    if (text.isEmpty) {
      logger.w('Text to speak is empty');
      return;
    }
    try {
      // Stop any ongoing speech
      await _flutterTts!.stop();

      // Set TTS parameters
      await _flutterTts!.setLanguage('ja-JP');
      await _flutterTts!.setPitch(1.0);
      await _flutterTts!.setSpeechRate(0.5);
      await _flutterTts!.setVolume(1.0);

      // Log and speak
      logger.i('Speaking: $text');
      await _flutterTts!.speak(text);
    } catch (e) {
      logger.e('Error in TTS: $e');
    }
  }

  @override
  void dispose() {
    _flutterTts?.stop();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _searchController.clear();
              _loadGreeting();
            },
          ),
        ],
      ),
      body: _errorMessage != null
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Error loading data: $_errorMessage'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _searchController.clear();
                    _loadGreeting();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          )
          : _greetings == null
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading data...'),
              ],
            ),
          )
          : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _greetings!.length,
                  itemBuilder: (context, index) {
                    final widget = _greetings![index];
                    if (widget is ListTile) {
                      final String? title = (widget.title as Text?)?.data;
                      final String? subtitle = (widget.subtitle as Text?)?.data;

                      return Card(
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5.0,
                        margin: const EdgeInsets.all(10.0),
                        child: ListTile(
                          title: Text(
                            title ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(subtitle ?? ''),
                          trailing: IconButton(
                            icon: Icon(Icons.volume_up),
                            onPressed: () {
                              _speak(title ?? '');
                            },
                          ),
                        ),
                      );
                    } else {
                      return widget;
                    }
                  },
                ),
              ),
            ],
          ),
    );
  }
}
