
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/hirakata/kana_quize.dart';


class Dialogqueue extends StatefulWidget {
  final Map<String, String> ganaList; // List of hiragana characters
  final Map<String, String> dakutenList; // List of dakuten characters
  final Map<String, String> combinationList; // List of combination characters

  const Dialogqueue({super.key, required this.ganaList, required this.dakutenList, required this.combinationList});

  @override
  State<Dialogqueue> createState() => _DialogqueueState();
}

class _DialogqueueState extends State<Dialogqueue> {
  int? selectedIndex; // Default value for selectedIndex

  final List<String> useCases = [
    'All Kana',
    'All Main Kana',
    'All Dakuten Kana',
    'All Combination Kana',
    'Irregular Kana',
    'Draw Kana',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Wrap(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choose a kana quiz',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                for (int i = 0; i < useCases.length; i++)
                  ListTile(
                    title: Text(useCases[i]),
                    leading: Radio<int>(
                      value: i,
                      groupValue: selectedIndex,
                      onChanged: (int? value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                    ),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  onPressed: selectedIndex != null
                      ? () {
                          // Handle selection
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                if (selectedIndex == 0) {
                                  // All Kana
                                  final Map<String, String> allKanaList = {};
                                  allKanaList.addAll(widget.ganaList);
                                  allKanaList.addAll(widget.dakutenList);
                                  allKanaList.addAll(widget.combinationList);
                                  return KanaQuize(
                                    title: useCases[selectedIndex!],
                                    kanaType: allKanaList,
                                    maxChar: 104,
                                  );
                                } else if (selectedIndex == 1) {
                                  // All Main Kana
                                  return KanaQuize(
                                    title: useCases[selectedIndex!],
                                    kanaType: widget.ganaList,
                                    maxChar: 46,
                                  );
                                } else if (selectedIndex == 2) {
                                  // All Dakuten Kana
                                  return KanaQuize(
                                    title: useCases[selectedIndex!],
                                    kanaType: widget.dakutenList,
                                    maxChar: 25,
                                  );
                                } else if (selectedIndex == 3) {
                                  // All Combination Kana
                                  return KanaQuize(
                                    title: useCases[selectedIndex!],
                                    kanaType: widget.combinationList,
                                    maxChar: 33,
                                  );
                                } else if (selectedIndex == 4) {
                                  // All Combination Kana
                                  return KanaQuize(
                                    title: useCases[selectedIndex!],
                                    kanaType: widget.combinationList,
                                    maxChar: 33,
                                  );
                                } else {
                                  // Fallback widget in case of unexpected index
                                  return Scaffold(
                                    body: Center(
                                      child: Text('Quiz not implemented for this selection.'),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        }
                      : null,
                    child: const Text("Let's start!"),
                  ),
                ),
              ],
            ),
            ),
          )
        ],
      )
    );
  }
}