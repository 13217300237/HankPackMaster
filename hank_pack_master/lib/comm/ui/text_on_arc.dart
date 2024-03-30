import 'dart:math' as math;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';


/// 圆形印章
class TextOnArcWidget extends StatelessWidget {
  final ArcStyle arcStyle;

  const TextOnArcWidget({
    super.key,
    required this.arcStyle,
  });

  double get size => arcStyle.radius * 2 + arcStyle.strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: TextOnArcPainter(style: arcStyle),
      ),
    );
  }
}

class ArcStyle {
  /// 文字内容
  final String text;

  /// 组件半径
  final double radius;

  /// 开始角度
  final double startDegrees;

  /// 扫过角度
  final double sweepDegrees;

  /// 文字颜色
  final Color textColor;

  /// 文字大小
  final double textSize;

  /// 文字字体
  final String textFamily;

  /// 文字字重
  final FontWeight fontWeight;

  /// 圆弧和字体的间距
  final double padding;

  /// 圆弧厚度
  final double strokeWidth;

  /// 圆弧颜色
  final Color arcColor;

  ArcStyle({
    required this.text,
    this.radius = 70,
    this.startDegrees = 155,
    this.sweepDegrees = 150,
    this.textColor = Colors.teal,
    this.textFamily = 'STKAITI',
    this.textSize = 20,
    this.fontWeight = FontWeight.w600,
    this.padding = 30,
    required this.strokeWidth,
    this.arcColor = Colors.teal,
  });
}

class TextOnArcPainter extends CustomPainter {
  final ArcStyle style;

  TextOnArcPainter({required this.style});

  double convertDegreesToRadians(double degrees) {
    return (degrees * pi) / 180;
  }

  double get startAngle => convertDegreesToRadians(style.startDegrees);

  double get sweepAngle => convertDegreesToRadians(style.sweepDegrees);

  double get arcStartAngle => convertDegreesToRadians(0);

  double get arcSweepAngle => convertDegreesToRadians(320);

  @override
  void paint(Canvas canvas, Size size) {
    _drawArcBg(canvas, size);
    _drawArc(canvas, size);
    _drawTextOnArc(canvas, size);
    _drawImg(canvas, size);
  }

  _drawArcBg(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = style.arcColor.withOpacity(.1)
      ..style = PaintingStyle.fill
      ..strokeWidth = style.strokeWidth;

    Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: style.radius,
    );

    canvas.drawArc(rect, arcStartAngle, pi * 2, false, paint);
  }

  _drawArc(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = style.arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.strokeWidth;

    Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: style.radius,
    );

    canvas.drawArc(rect, arcStartAngle, arcSweepAngle, false, paint);
  }

  _drawTextOnArc(Canvas canvas, Size size) {
    var thisRadius = style.radius - style.padding;

    final paragraphStyle = ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: style.textSize,
        fontWeight: style.fontWeight,
        fontFamily: style.textFamily,
        fontStyle: FontStyle.normal);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    canvas.save();
    canvas.translate(centerX, centerY);

    final double angleStep = sweepAngle / style.text.length;
    for (int i = 0; i < style.text.length; i++) {
      final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(ui.TextStyle(color: style.textColor))
        ..addText(style.text[i]);
      final constraints = ui.ParagraphConstraints(width: 2 * thisRadius);
      final paragraph = paragraphBuilder.build()..layout(constraints);
      final angle = startAngle + i * angleStep;
      final dx = math.cos(angle) * thisRadius;
      final dy = math.sin(angle) * thisRadius;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(angle + math.pi / 2);
      canvas.drawParagraph(
          paragraph, Offset(-paragraph.width / 2, -paragraph.height / 2));
      canvas.restore();
    }

    canvas.restore();
  }

  _drawImg(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = style.arcColor
      ..style = PaintingStyle.fill;

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = size.width / 7;

    double angle = 4 * pi / 5; // 五角星每个角的弧度

    Path path = Path();
    path.moveTo(centerX, centerY - radius);

    for (int i = 1; i <= 5; i++) {
      double x = centerX + radius * sin(i * angle);
      double y = centerY - radius * cos(i * angle);
      path.lineTo(x, y);
    }

    path.close(); // 闭合路径

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
