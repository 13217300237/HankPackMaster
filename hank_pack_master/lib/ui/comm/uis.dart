import 'package:flutter/material.dart';

/// 呼吸灯组件
class BreathingIndicator extends StatefulWidget {
  final double size;

  final Widget child;

  const BreathingIndicator({
    Key? key,
    required this.size,
    required this.child,
  }) : super(key: key);

  @override
  BreathingIndicatorState createState() => BreathingIndicatorState();
}

class BreathingIndicatorState extends State<BreathingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _opacityAnimationController;

  @override
  void initState() {
    super.initState();
    _opacityAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _opacityAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _opacityAnimationController,
        builder: (BuildContext context, Widget? child) {
          return Center(
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightGreen
                    .withOpacity(_opacityAnimationController.value),
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
