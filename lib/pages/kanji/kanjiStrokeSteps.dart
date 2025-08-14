import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class KanjistrokeSteps extends CustomPainter {
  final int frame;
  //svgPathList
  final List svgPathList;

  KanjistrokeSteps({
    required this.frame,
    required this.svgPathList,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    _drawDashedLine(canvas, Offset(size.width / 2, 0), Offset(size.width / 2, size.height), gridPaint);
    _drawDashedLine(canvas, Offset(0, size.height / 2), Offset(size.width, size.height / 2), gridPaint);

    final Paint pathPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < frame && i < svgPathList.length; i++) {
      final path = parseSvgPathData(svgPathList[i]);
      canvas.drawPath(path, pathPaint);
    }

    if (frame > 0 && frame <= svgPathList.length) {
      final path = parseSvgPathData(svgPathList[frame - 1]);
      final metrics = path.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final tangent = metrics.first.getTangentForOffset(0);
        if (tangent != null) {
          final pos = tangent.position;
          final Paint dotPaint = Paint()
            ..color = Colors.red
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos.translate(2, -1), 4, dotPaint);
        }
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    final path = Path()..moveTo(start.dx, start.dy)..lineTo(end.dx, end.dy);
    final dashedPath = dashPath(path, dashArray: CircularIntervalList([dashWidth, dashSpace]));
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}