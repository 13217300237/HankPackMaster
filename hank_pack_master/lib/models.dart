import 'package:flutter/cupertino.dart';

class ExecutorModel extends ChangeNotifier {
  List<String> lines = [];

  final ScrollController _scrollController = ScrollController();

  ScrollController get scrollController => _scrollController;

  List<String> get getRes => lines;

  reset() {
    lines = [];
    notifyListeners();
  }

  append(String res) {
    lines.add(res);
    notifyListeners();
    scrollToBottom();
  }

  void scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }
}
