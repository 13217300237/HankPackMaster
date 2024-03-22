import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'dart:math' as math;

class TextOnArcPainter extends CustomPainter {
  final String text;
  final double radius;
  final double startAngle;
  final double sweepAngle;

  TextOnArcPainter({
    required this.text,
    required this.radius,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paragraphStyle =
        ui.ParagraphStyle(textAlign: TextAlign.center, fontSize: 16);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    canvas.save();
    canvas.translate(centerX, centerY);

    final double angleStep = sweepAngle / text.length;
    for (int i = 0; i < text.length; i++) {
      final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(ui.TextStyle(color: Colors.black))
        ..addText(text[i]);
      final constraints = ui.ParagraphConstraints(width: 2 * radius);
      final paragraph = paragraphBuilder.build()..layout(constraints);
      final angle = startAngle + i * angleStep;
      final dx = math.cos(angle) * radius;
      final dy = math.sin(angle) * radius;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(angle + math.pi / 2);
      canvas.drawParagraph(
          paragraph, Offset(-paragraph.width / 2, -paragraph.height / 2));
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
