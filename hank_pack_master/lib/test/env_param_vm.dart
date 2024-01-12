import 'package:flutter/cupertino.dart';

import '../comm/sp_util.dart';

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

  bool isEnvEmpty(String title) {
    String? v;
    switch (title) {
      case "git":
        v = gitRoot;
        break;
      case "flutter":
        v = flutterRoot;
        break;
      case "adb":
        v = adbRoot;
        break;
      case "android":
        v = androidSdkRoot;
        break;
      case "java":
        v = javaRoot;
        break;
      case "workSpaceRoot":
        v = workSpaceRoot;
        break;
    }
    return v?.isEmpty ?? false;
  }

  bool judgeEnv(String title, String value) {
    switch (title) {
      case "git":
        return gitRoot == value;
      case "flutter":
        return flutterRoot == value;
      case "adb":
        return adbRoot == value;
      case "android":
        return androidSdkRoot == value;
      case "java":
        return javaRoot == value;
      case "workSpaceRoot":
        return workSpaceRoot == value;
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

  String get gitRoot => SpUtil.getValue(SpConst.envGitKey) ?? "";

  set gitRoot(String r) {
    SpUtil.putValue(SpConst.envGitKey, r);
    notifyListeners();
  }

  String get flutterRoot => SpUtil.getValue(SpConst.envFlutterKey) ?? "";

  set flutterRoot(String r) {
    SpUtil.putValue(SpConst.envFlutterKey, r);
    notifyListeners();
  }

  String get adbRoot => SpUtil.getValue(SpConst.envAdbKey) ?? "";

  set adbRoot(String r) {
    SpUtil.putValue(SpConst.envAdbKey, r);
    notifyListeners();
  }

  String get androidSdkRoot => SpUtil.getValue(SpConst.envAndroidKey) ?? "";

  set androidSdkRoot(String r) {
    SpUtil.putValue(SpConst.envAndroidKey, r);
    notifyListeners();
  }

  String get javaRoot => SpUtil.getValue(SpConst.envJavaKey) ?? "";

  set javaRoot(String r) {
    SpUtil.putValue(SpConst.envJavaKey, r);
    notifyListeners();
  }

  String get workSpaceRoot =>
      SpUtil.getValue(SpConst.envWorkspaceRootKey) ?? "";

  set workSpaceRoot(String r) {
    SpUtil.putValue(SpConst.envWorkspaceRootKey, r);
    notifyListeners();
  }

  bool isEnvChecked() {
    return SpUtil.getValue(SpConst.envAndroidKey);
  }

  bool isAndroidEnvOk() {
    if (workSpaceRoot.isEmpty) {
      return false;
    }

    if (androidSdkRoot.isEmpty) {
      return false;
    }

    return true;
  }
}
