import 'package:fluent_ui/fluent_ui.dart';

import 'package:provider/provider.dart';

class MyNotifier extends ChangeNotifier {
  bool _isActivated = false;

  bool get isActivated => _isActivated;

  void updateStatus(bool activated) {
    _isActivated = activated;
    notifyListeners();
  }
}

class MyCustomWidget extends StatelessWidget {
  const MyCustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyNotifier>(builder: (context, notifier, child) {
      return GestureDetector(
          onTap: () => notifier.updateStatus(!notifier.isActivated),
          child: Container(
              width: 100,
              height: 100,
              color: notifier.isActivated ? Colors.blue : Colors.grey,
              child: Center(
                  child: Text(
                notifier.isActivated ? 'Activated' : 'Deactivated',
                style: const TextStyle(color: Colors.white),
              ))));
    });
  }
}
