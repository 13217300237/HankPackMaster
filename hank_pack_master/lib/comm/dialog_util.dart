import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class DialogUtil {
  static void showConfirmDialog({
    required BuildContext context,
    Function? onConfirm,
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            FilledButton(
              child: const Text('是'),
              onPressed: () {
                Navigator.pop(context);
                onConfirm?.call();
              },
            ),
            Button(
              child: const Text('取消'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
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
          title: Text(title),
          content: Text(content),
          actions: [
            Button(
              child: const Text('拷贝结果'),
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
}
