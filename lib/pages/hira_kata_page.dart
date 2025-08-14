import 'package:flutter/material.dart';
import 'package:flutter_app/pages/hirakata/letter_page.dart';
import 'package:flutter_app/pages/hirakata/letter_test.dart';

class HiraKataApp extends StatelessWidget {
  const HiraKataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HiraKataPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HiraKataPage extends StatelessWidget {
  final Color pinkColor = const Color(0xFFFFEBEE);
  final Color darkPink = const Color(0xFFF8BBD0);
  final Color strongPink = const Color(0xFFF48FB1);

  const HiraKataPage({super.key});

  void _handleStudyAction(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudyPage(type: type),
      ),
    );
  }

  void _handleCharacterTestAction(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterTestPage(type: type),
      ),
    );
  }

  void _handleWordTestAction(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordTestPage(type: type),
      ),
    );
  }

  void _handleSectionClearAction(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$type セクションクリア'),
        content: Text('$typeのセクションをクリアしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$typeセクションをクリアしました！')),
              );
            },
            child: const Text('クリア'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pinkColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiragana Card
            buildLanguageCard(
              title: "ひらがな",
              subtitle: "基本の文字",
              progress: 0.1,
              color: strongPink,
              buttons: [
                buildCard(Icons.menu_book, "学習", strongPink, () => _handleStudyAction(context, 'ひらがな')),
                buildCard(Icons.edit, "文字テスト", strongPink, () => _handleCharacterTestAction(context, 'ひらがな')),
                buildCard(Icons.record_voice_over, "単語テスト", strongPink, () => _handleWordTestAction(context, 'ひらがな')),
                buildCard(Icons.check_circle, "セクションクリア", strongPink, () => _handleSectionClearAction(context, 'ひらがな')),
              ],
            ),
            const SizedBox(height: 20),
            
            // Katakana Card
            buildLanguageCard(
              title: "カタカナ",
              subtitle: "基本の文字",
              progress: 0.8,
              color: darkPink,
              buttons: [
                buildCard(Icons.menu_book, "学習", darkPink, () => _handleStudyAction(context, 'カタカナ')),
                buildCard(Icons.edit, "文字テスト", darkPink, () => _handleCharacterTestAction(context, 'カタカナ')),
                buildCard(Icons.record_voice_over, "単語テスト", darkPink, () => _handleWordTestAction(context, 'カタカナ')),
                buildCard(Icons.check_circle, "セクションクリア", darkPink, () => _handleSectionClearAction(context, 'カタカナ')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLanguageCard({
    required String title,
    required String subtitle,
    required double progress,
    required Color color,
    required List<Widget> buttons,
  }) {
    return Column(
      children: [
        // Title and Progress Card
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: color,
                            )),
                        Text(subtitle,
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("${(progress * 100).toInt()}%",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            )),
                        const Text("完了",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  color: color,
                  minHeight: 8,
                ),
                const SizedBox(height: 10),
                // Buttons Grid
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: buttons,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansJP',
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  StudyPage({required String type}) {
    if (type == 'ひらがな') {
      return LetterPage(title: 'Hiragana');
    } else if (type == 'カタカナ') {
      return LetterPage(title: 'Katakana');
    }
  }
  
  CharacterTestPage({required String type}) {
    if (type == 'ひらがな') {
      return LetterTest(title: 'Hiragana');
    } else if (type == 'カタカナ') {
      return LetterTest(title: 'Katakana');
    }
  }
  
  WordTestPage({required String type}) {
    if (type == 'ひらがな') {
      return const Center(child: Text('Hiragana Word Test Page'));
    } else if (type == 'カタカナ') {
      return const Center(child: Text('Katakana Word Test Page'));
    }
  }
}
