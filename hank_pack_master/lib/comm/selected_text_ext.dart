import 'package:fluent_ui/fluent_ui.dart';

extension SetStyle on SelectableText {
  Widget style1() {
    return TextSelectionTheme(
      data: TextSelectionThemeData(
        selectionColor: Colors.green.withOpacity(.3),
        // 修改选中文本的背景颜色
        selectionHandleColor: Colors.red, // 修改选中文本的选择手柄颜色
      ),
      child: this,
    );
  }
}
