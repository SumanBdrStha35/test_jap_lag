
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_app/dialog/dialogQueue.dart';
import 'package:flutter_tts/flutter_tts.dart';
class LetterPage extends StatefulWidget  {
  final String title;
  const LetterPage({super.key, required this.title});

  @override
  State<LetterPage> createState() => _LetterPageState();
}

class _LetterPageState extends State<LetterPage> {
  late final Map<String, String> ganaList;
  late final Map<String, String> dakutenList;
  late final Map<String, String> combinationList;
  late FlutterTts flutterTts;
   bool isLoading = true;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ja-JP");
    loadData(); 
  }

   Future<void> loadData() async {
    try {
      if (widget.title == "Hiragana") {
        final jsonString = await rootBundle.loadString('assets/data/hiragana_data.json');
        final jsonData = json.decode(jsonString);
        
        setState(() {
          ganaList = Map<String, String>.from(jsonData['hiraganaList']);
          dakutenList = Map<String, String>.from(jsonData['dakutenList']);
          combinationList = Map<String, String>.from(jsonData['combinationList']);
          isLoading = false;
        });
      } else if (widget.title == "Katakana") {
        final jsonString = await rootBundle.loadString('assets/data/katakana_data.json');
        final jsonData = json.decode(jsonString);
        
        setState(() {
          ganaList = Map<String, String>.from(jsonData['katakanaList']);
          dakutenList = Map<String, String>.from(jsonData['dakutenList']);
          combinationList = Map<String, String>.from(jsonData['combinationList']);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
  
  Future<void> speak(String text) async {
    try {
      // await Future.delayed(const Duration(milliseconds: 500));
      await flutterTts.setLanguage("ja-JP"); // Set language to Japanese
      await flutterTts.setSpeechRate(0.5); // Set speech rate to 0.5
      await flutterTts.setVolume(1.0); // Set volume to 1.0
      await flutterTts.setPitch(1.0); // Set pitch to 1.0
      await flutterTts.awaitSpeakCompletion(true); // Wait for the speech to complete
      // await flutterTts.setVoice({"name": "en-us-x-sfg#male_1-local", "locale": "en-US"}); //set voice to
      var result = await flutterTts.speak(text); // Speak the text
      if (result == 1) {
        print("Speech started successfully");
      } else {
        print("Speech failed to start");
      }      
    } catch (e) {
      // Handle TTS errors here if needed
      print("Error in TTS speak: \$e");
    }
  }
  
  // for BottomNavigationBar
  void _showModalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Dialogqueue(
        ganaList: ganaList,
        dakutenList: dakutenList,
        combinationList: combinationList,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBEE),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            InkWell(
              onTap: () {
                // _showModalSheet(context);
                SnackBar snackBar = SnackBar(
                  content: Text("This feature is under development."),
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Lessons wise",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(widget.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: ganaList.length,
              itemBuilder: (context, index) {
                final entry = ganaList.entries.elementAt(index);
                if (entry.key.startsWith('_empty')) {
                  return const SizedBox.shrink();
                }
                return GestureDetector(
                  onTap: () {
                    speak(entry.value);
                  },
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Color(0xFFF48FB1), width: 1.0),
                    ),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.value,
                          style: TextStyle(
                              color: Color(0xFFF48FB1), 
                              fontSize: 30, 
                              fontWeight: FontWeight.bold
                            ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.key,
                          style: TextStyle(
                              color: Color.fromARGB(255, 26, 166, 247), 
                              fontSize: 15, 
                              fontWeight: FontWeight.bold
                            ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            Text('Dakuten', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: dakutenList.length,
              itemBuilder: (context, index) {
                final entry = dakutenList.entries.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    speak(entry.value);
                  },
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Color(0xFFF48FB1), width: 1.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.value,
                          style: TextStyle(color: Color(0xFFF48FB1), fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.key,
                          style: TextStyle(color: Color.fromARGB(255, 26, 166, 247), fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            Text('Combination', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: combinationList.length,
              itemBuilder: (context, index) {
                final entry = combinationList.entries.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    speak(entry.value);
                  },
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Color(0xFFF48FB1), width: 1.0),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            entry.value,
                            style: TextStyle(color: Color(0xFFF48FB1), fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.key,
                            style: TextStyle(color: Color.fromARGB(255, 26, 166, 247), fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
}
