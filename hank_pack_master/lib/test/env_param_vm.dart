import 'package:flutter/cupertino.dart';

class EnvParamVm extends ChangeNotifier {
  List<String> logLines = [];

  final ScrollController _scrollController = ScrollController();

  ScrollController get scrollController => _scrollController;

  List<String> get getRes => logLines;

  resetLogPanel() {
    logLines = [];
    notifyListeners();
  }

  appendLog(String res) {
    logLines.add(res);
    notifyListeners();
    scrollLogPanelToBottom();
  }

  void scrollLogPanelToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  String _gitRoot = "";
  String _flutterRoot = "";
  String _adbRoot = "";
  String _androidSdkRoot = "";
  String _javaRoot = "";
  String _workSpaceRoot = "";

  bool isEnvEmpty(String title) {
    String? v;
    switch (title) {
      case "git":
        v = _gitRoot;
        break;
      case "flutter":
        v = _flutterRoot;
        break;
      case "adb":
        v = _adbRoot;
        break;
      case "android":
        v = _androidSdkRoot;
        break;
      case "java":
        v = _javaRoot;
        break;
      case "workSpaceRoot":
        v = _workSpaceRoot;
        break;
    }
    return v?.isEmpty ?? false;
  }

  bool judgeEnv(String title, String value) {
    switch (title) {
      case "git":
        return _gitRoot == value;
      case "flutter":
        return _flutterRoot == value;
      case "adb":
        return _adbRoot == value;
      case "android":
        return _androidSdkRoot == value;
      case "java":
        return _javaRoot == value;
      case "workSpaceRoot":
        return _workSpaceRoot == value;
    }
    return false;
  }

  void setEnv(String title, String value) {
    switch (title) {
      case "git":
        gitRoot = value;
        break;
      case "flutter":
        flutterRoot = value;
        break;
      case "adb":
        adbRoot = value;
        break;
      case "android":
        androidSdkRoot = value;
        break;
      case "java":
        javaRoot = value;
        break;
      case "workSpaceRoot":
        workSpaceRoot = value;
    }
  }

  String get gitRoot => _gitRoot;

  set gitRoot(String r) {
    _gitRoot = r;
    notifyListeners();
  }

  String get flutterRoot => _flutterRoot;

  set flutterRoot(String r) {
    _flutterRoot = r;
    notifyListeners();
  }

  String get adbRoot => _adbRoot;

  set adbRoot(String r) {
    _adbRoot = r;
    notifyListeners();
  }

  String get androidSdkRoot => _androidSdkRoot;

  set androidSdkRoot(String r) {
    _androidSdkRoot = r;
    notifyListeners();
  }

  String get javaRoot => _javaRoot;

  set javaRoot(String r) {
    _javaRoot = r;
    notifyListeners();
  }

  String get workSpaceRoot => _workSpaceRoot;

  set workSpaceRoot(String r) {
    _workSpaceRoot = r;
    notifyListeners();
  }

  bool isAndroidEnvOk()  {

    if(_workSpaceRoot.isEmpty){
      return false;
    }

    if(_androidSdkRoot.isEmpty){
      return false;
    }

    return true;
  }
}
