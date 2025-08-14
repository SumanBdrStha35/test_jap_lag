import 'package:flutter/material.dart';
import 'package:flutter_app/pages/kanji/kanjiStrokeSteps.dart';

class KanjiStrokeFrame extends StatelessWidget {
  final int frameIndex;
  final List<dynamic> gif;
  // Constructor to initialize the frame index and gif data
  const KanjiStrokeFrame({super.key, required this.frameIndex, required this.gif});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown, width: 2),
      ),
      child: CustomPaint(
        painter: KanjistrokeSteps(
          frame: frameIndex,
          svgPathList: gif,
        ),
      ),
    );
  }
}