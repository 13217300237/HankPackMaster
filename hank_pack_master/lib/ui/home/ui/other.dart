import 'dart:math' as math;
import 'package:flutter/material.dart';

///
/// 自带旋转的Widget Wrapper
///
class RotationImageWidget extends StatefulWidget {
  final Widget child;

  const RotationImageWidget({Key? key, required this.child}) : super(key: key);

  @override
  RotationImageWidgetState createState() => RotationImageWidgetState();
}

class RotationImageWidgetState extends State<RotationImageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        snapshot.data;
        return Container();
      },
      future: null,
    );

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return widget.child;
        },
      ),
    );
  }
}
