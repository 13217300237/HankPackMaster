import 'package:fluent_ui/fluent_ui.dart';

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

  static void showCustomContentDialog({
    required BuildContext context,
    Function? onConfirm,
    required Widget child,
    required String title,
  }) async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: Text(title),
          content: child,
          actions: [
            Button(
              child: const Text('确认'),
              onPressed: () {
                Navigator.pop(context);
                // Delete file here
              },
            ),
            FilledButton(
              child: const Text('取消'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
