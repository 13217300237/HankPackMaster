import 'package:fluent_ui/fluent_ui.dart';

/// 横向填满父容器的InfoBar
Widget expandedInfoBar(String tips, {VoidCallback? onClose}) {
  return InfoBar(
    title: const Text('提示',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    content: SizedBox(
      width: double.infinity,
      child: Text(tips,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    ),
    severity: InfoBarSeverity.info,
    isLong: true,
    onClose: onClose,
  );
}
