import 'package:flutter/cupertino.dart';

class ExecutorModel extends ChangeNotifier {
  List<String> lines = [];

  List<String> get getRes => lines;

  reset() {
    lines = [];
    notifyListeners();
  }

  append(String res) {
    lines.add(res);
    notifyListeners();
  }
}
