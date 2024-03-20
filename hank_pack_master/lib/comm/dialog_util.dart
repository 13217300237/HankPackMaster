import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hank_pack_master/comm/gradients.dart';
import 'package:hank_pack_master/comm/ui/xGate_widget.dart';

class DialogUtil {
  ///
  ///
  /// [content] 动态类型，如果传 String，则解析成 Text，如果是Widget，则直接赋值
  ///
  static Future showCustomDialog({
    required BuildContext context,
    Function? onConfirm,
    bool Function()? judgePop,
    required String title,
    required dynamic content,
    bool showCancel = true,
    bool showActions = true,
    String confirmText = "是",
    String cancelText = "取消",
    double maxWidth = 500,
    double maxHeight = 700,
    bool showXGate = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          style: ContentDialogThemeData(
            actionsDecoration: BoxDecoration(
              color: const Color(0xFFF6EFE9),
              borderRadius: BorderRadius.circular(10),
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFF6EFE9)),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              showXGate ? const XGateWidget() : const SizedBox(),
            ],
          ),
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
          content: content is Widget
              ? Row(children: [Expanded(child: content)])
              : SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
          actions: showActions
              ? [
                  FilledButton(
                    child: Text(
                      confirmText,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      if (judgePop == null || judgePop()) {
                        Navigator.pop(context);
                      }
                      onConfirm?.call();
                    },
                  ),
                  if (showCancel)
                    Button(
                      child: Text(cancelText),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                ]
              : null,
        );
      },
    );
  }

  static void showEnvCheckDialog({
    required BuildContext context,
    Function? onConfirm,
    required String content,
    required String title,
  }) async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 30),
          ),
          content: SelectableText(content,
              style: const TextStyle(color: Colors.grey, fontSize: 16)),
          actions: [
            Button(
              child: const Text(
                '拷贝结果',
              ),
              onPressed: () {
                Navigator.pop(context);
                FlutterClipboard.copy(content).then((value) {
                  EasyLoading.showToast("拷贝成功");
                });
              },
            ),
            FilledButton(
                child: const Text('关闭'),
                onPressed: () => Navigator.pop(context)),
          ],
        );
      },
    );
  }

  static Future<void> showInfo({
    required BuildContext context,
    String title = "提示",
    required String content,
    InfoBarSeverity severity = InfoBarSeverity.success,
  }) async {
    await displayInfoBar(context, builder: (context, close) {
      return InfoBar(
          title: Text(title),
          content: Text(content),
          action: IconButton(
              icon: const Icon(FluentIcons.chrome_close), onPressed: close),
          severity: severity);
    });
  }
}
