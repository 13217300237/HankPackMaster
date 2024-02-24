import 'package:flutter/material.dart';

class AnimatedShapeWidget extends StatefulWidget {
  final double width;
  final double height;
  final double startBorderRadius;
  final double endBorderRadius;
  final Duration animationDuration;
  final Color startColor;
  final Color endColor;

  const AnimatedShapeWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.startBorderRadius,
    required this.endBorderRadius,
    required this.animationDuration,
    required this.startColor,
    required this.endColor,
  }) : super(key: key);

  @override
  AnimatedShapeWidgetState createState() => AnimatedShapeWidgetState();
}

class AnimatedShapeWidgetState extends State<AnimatedShapeWidget>
    with SingleTickerProviderStateMixin {
  late double _currentBorderRadius;
  late Color _currentColor;
  bool statueTag = false;

  @override
  void initState() {
    super.initState();
    _currentBorderRadius = widget.startBorderRadius;
    _currentColor = widget.startColor;
  }

  void change() {
    setState(() {
      if (!statueTag) {
        _currentBorderRadius = widget.endBorderRadius;
        _currentColor = widget.endColor;
      } else {
        _currentBorderRadius = widget.startBorderRadius;
        _currentColor = widget.startColor;
      }

      statueTag = !statueTag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        change();
      },
      child: AnimatedContainer(
        width: widget.width,
        height: widget.height,
        duration: widget.animationDuration,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_currentBorderRadius),
          color: _currentColor,
        ),
      ),
    );
  }
}
