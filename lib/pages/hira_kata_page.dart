import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_app/pages/hirakata/letter_page.dart';
import 'package:flutter_app/pages/hirakata/letter_test.dart';

class HiraKataApp extends StatelessWidget {
  const HiraKataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HiraKataPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HiraKataPage extends StatelessWidget {
  final Color pinkColor = const Color(0xFFFF9AD5);
  final Color purpleColor = const Color(0xFFB399FF);
  List<Color> get gColorsList => [pinkColor, purpleColor];

  const HiraKataPage({super.key});

  void _handleStudyAction(BuildContext context, String type) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => StudyPage(type: type),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: 500.ms,
      ),
    );
  }

  void _handleCharacterTestAction(BuildContext context, String type) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CharacterTestPage(type: type),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: 500.ms,
      ),
    );
  }

  void _handleWordTestAction(BuildContext context, String type) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => WordTestPage(type: type),
        transitionsBuilder: (_, animation, __, child) {
          return ScaleTransition(scale: animation, child: child);
        },
        transitionDuration: 500.ms,
      ),
    );
  }

  void _handleSectionClearAction(BuildContext context, String type) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                    SnackBar(
                      content: Text('$typeセクションをクリアしました！'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(milliseconds: 500),
                    ),
                    // animate().slideY(
                    //   begin: 1,
                    //   end: 0,
                    //   curve: Curves.easeOutBack,
                    // ),
                  );
                },
                child: const Text('クリア'),
              ),
            ],
          ).animate().scaleXY(begin: 0.8, end: 1, curve: Curves.easeOutBack),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gColorsList,
            stops: [0.0, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hiragana Card
                buildLanguageCard(
                      title: "ひらがな",
                      subtitle: "基本の文字",
                      progress: 0.1,
                      color: pinkColor,
                      buttons: [
                        buildCard(
                          Icons.menu_book,
                          "学習",
                          pinkColor,
                          () => _handleStudyAction(context, 'ひらがな'),
                        ),
                        buildCard(
                          Icons.edit,
                          "文字テスト",
                          pinkColor,
                          () => _handleCharacterTestAction(context, 'ひらがな'),
                        ),
                        buildCard(
                          Icons.record_voice_over,
                          "単語テスト",
                          pinkColor,
                          () => _handleWordTestAction(context, 'ひらがな'),
                        ),
                        buildCard(
                          Icons.check_circle,
                          "セクションクリア",
                          pinkColor,
                          () => _handleSectionClearAction(context, 'ひらがな'),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.5, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),

                // Katakana Card
                buildLanguageCard(
                      title: "カタカナ",
                      subtitle: "基本の文字",
                      progress: 0.8,
                      color: purpleColor,
                      buttons: [
                        buildCard(
                          Icons.menu_book,
                          "学習",
                          purpleColor,
                          () => _handleStudyAction(context, 'カタカナ'),
                        ),
                        buildCard(
                          Icons.edit,
                          "文字テスト",
                          purpleColor,
                          () => _handleCharacterTestAction(context, 'カタカナ'),
                        ),
                        buildCard(
                          Icons.record_voice_over,
                          "単語テスト",
                          purpleColor,
                          () => _handleWordTestAction(context, 'カタカナ'),
                        ),
                        buildCard(
                          Icons.check_circle,
                          "セクションクリア",
                          purpleColor,
                          () => _handleSectionClearAction(context, 'カタカナ'),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.5, end: 0, curve: Curves.easeOutCubic),
              ],
            ),
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
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
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text("完了", style: TextStyle(color: Colors.grey)),
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
                    )
                    .animate(delay: 600.ms)
                    .scaleX(
                      begin: 0,
                      end: 1,
                      duration: 800.ms,
                      curve: Curves.easeOutQuad,
                    ),
                const SizedBox(height: 10),
                // Buttons Grid
                Wrap(spacing: 10, runSpacing: 10, children: buttons),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCard(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32)
                .animate()
                .scale(
                  duration: 100.ms,
                  begin: const Offset(1, 1),
                  end: const Offset(0.9, 0.9),
                )
                .then()
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ).animate().fadeIn().scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1, 1),
        curve: Curves.elasticOut,
      ),
    );
  }

  LetterPage StudyPage({required String type}) {
    if (type == 'ひらがな') {
      return LetterPage(title: 'Hiragana');
    } else if (type == 'カタカナ') {
      return LetterPage(title: 'Katakana');
    } else{
      throw ArgumentError('Invalid type: $type');
    }
  }

  LetterTest CharacterTestPage({required String type}) {
    if (type == 'ひらがな') {
      return LetterTest(title: 'Hiragana');
    } else if (type == 'カタカナ') {
      return LetterTest(title: 'Katakana');
    }else{
      throw ArgumentError('Invalid type: $type');
    }
  }

  Center WordTestPage({required String type}) {
    if (type == 'ひらがな') {
      return const Center(child: Text('Hiragana Word Test Page'));
    } else if (type == 'カタカナ') {
      return const Center(child: Text('Katakana Word Test Page'));
    }else{
      throw ArgumentError('Invalid type: $type');
    }
  }
}
