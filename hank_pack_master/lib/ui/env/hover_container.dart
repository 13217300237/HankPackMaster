import 'package:fluent_ui/fluent_ui.dart';

/// 鼠标悬停时发生动态变化的Container
class HoverContainer extends StatefulWidget {
  final Widget child;

  const HoverContainer({super.key, required this.child});

  @override
  State<HoverContainer> createState() => _HoverContainerState();
}

class _HoverContainerState extends State<HoverContainer> {
  Color borderColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (e) {
        setState(() {
          borderColor = Colors.transparent;
        });
      },
      onEnter: (e) {
        setState(() {
          borderColor = Colors.green;
        });
      },
      child: AnimatedContainer(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
            border: Border.all(width: 3, color: borderColor),
            borderRadius: BorderRadius.circular(8)),
        duration: const Duration(milliseconds: 150),
        child: widget.child,
      ),
    );
  }
}
