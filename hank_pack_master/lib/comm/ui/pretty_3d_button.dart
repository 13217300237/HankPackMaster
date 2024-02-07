import 'package:fluent_ui/fluent_ui.dart';

class Pretty3DButton extends StatefulWidget {
  final String text;
  final double? height;
  final double? width;
  final double blurRadius;
  final double offset;
  final double spreadRadius;
  final double? buttonBorderRadius;
  final Function? onTap;
  final bool enable;

  const Pretty3DButton({
    super.key,
    required this.text,
    this.height,
    this.width,
    required this.blurRadius,
    required this.offset,
    required this.spreadRadius,
    this.buttonBorderRadius,
    this.onTap,
    this.enable = true,
  });

  @override
  State<StatefulWidget> createState() {
    return Pretty3DButtonState();
  }
}

class Pretty3DButtonState extends State<Pretty3DButton> {
  bool _isElevated = true;
  final animationDuration = const Duration(milliseconds: 80);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enable) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
            color: Colors.grey[80],
            borderRadius:
                BorderRadius.circular(widget.buttonBorderRadius ?? 8)),
        height: widget.height,
        width: widget.width,
        child: Center(
            child: Text(
          widget.text,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        )),
      );
    } else {
      return GestureDetector(
          onTap: () => widget.onTap?.call(),
          onTapDown: (TapDownDetails details) =>
              setState(() => _isElevated = false),
          onTapUp: (TapUpDetails details) => setState(() => _isElevated = true),
          onTapCancel: () => setState(() => _isElevated = true),
          child: AnimatedContainer(
            duration: animationDuration,
            height: widget.height,
            width: widget.width,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.blue.withOpacity(.5),
                borderRadius:
                    BorderRadius.circular(widget.buttonBorderRadius ?? 8),
                boxShadow: _isElevated
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(.3),
                          offset: Offset(widget.offset, widget.offset), // 偏移量
                          blurRadius: widget.blurRadius, // 模糊半径
                          spreadRadius: widget.spreadRadius, // 扩散半径
                        ),
                        BoxShadow(
                          color: Colors.blue.lightest,
                          offset: Offset(-widget.offset, -widget.offset),
                          blurRadius: widget.blurRadius,
                          spreadRadius: widget.spreadRadius,
                        )
                      ]
                    : null),
            child: Center(
                child: Text(
              widget.text,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isElevated ? Colors.white : Colors.grey[80]),
            )),
          ));
    }
  }
}
