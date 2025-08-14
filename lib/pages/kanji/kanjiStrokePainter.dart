import 'package:flutter/material.dart';

class KanjiStrokePainter extends CustomPainter {
  final List<Path> strokes;
  final double currentProgress;

  KanjiStrokePainter({
    required this.strokes, 
    required this.currentProgress
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 127, 197, 255)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final textStyle = const TextStyle(
      fontStyle: FontStyle.normal,
      color: Colors.red,
      fontSize: 10,
    );

    final scale = size.width / 109.0;
    canvas.scale(scale, scale);

    for (int i = 0; i < strokes.length; i++) {
      final path = strokes[i];
      final metrics = path.computeMetrics().toList();
      for (var metric in metrics) {
        final length = metric.length;
        final drawLength = i == strokes.length - 1
            ? length * currentProgress
            : length;
        final partialPath = metric.extractPath(0, drawLength);
        canvas.drawPath(partialPath, paint);
        final startTangent = metric.getTangentForOffset(0);
        if (startTangent != null) {
          final offset = startTangent.position;
          final textSpan = TextSpan(text: '${i + 1}', style: textStyle);
          final tp = TextPainter(
            text: textSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, offset.translate(-tp.width / 2, -tp.height / 2));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant KanjiStrokePainter oldDelegate) =>
      oldDelegate.currentProgress != currentProgress ||
      oldDelegate.strokes.length != strokes.length;
}