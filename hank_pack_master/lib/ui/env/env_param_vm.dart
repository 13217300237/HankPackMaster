import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../comm/sp_util.dart';
import '../../core/command_util.dart';

class EnvParamVm extends ChangeNotifier {
  /// 环境有问题时的错误提示
  final Map<String, String> envGuide = {
    "git": "请在系统环境变量的path中插入git的可执行路径,形如 D:\\...\\git\\Git\\bin",
    "adb": "请在系统环境变量的path中插入adb的可执行路径,形如：D:\\...\\Android\\Sdk\\platform-tools",
    "java": "请在系统环境变量的path中插入java的可执行路径,形如 D:\\...\\as\\jbr\\bin",
    "android": "请在系统环境变量中插入 ANDROID_HOME变量，值为 SDK根路径，形如：D:\\...\\Android\\SDK"
  };

  Map<String, Set<String>> envs = {};

  final ScrollController _scrollController = ScrollController();

  ScrollController get scrollController => _scrollController;

  checkAction(
      {bool showLoading = true,
      required Function(String warn) warnAction}) async {
    if (showLoading) {
      EasyLoading.show(
          status: '正在初始化环境参数...', maskType: EasyLoadingMaskType.clear);
    }
    envs = await CommandUtil.getInstance().initAllEnvParam(action: (r) {
      debugCmdPrint("环境检索的日志输出:$r");
    });
    List<String> lostArr = [];
    envs.forEach((title, value) {
      var first = value.firstOrNull;
      if (first != null) {
        setEnv(title, first);
      } else {
        lostArr.add(title);
      }
    });

    if (showLoading) {
      EasyLoading.dismiss();
    }

    if (lostArr.isNotEmpty) {
      warnAction('''$lostArr 存在环境缺陷，请补齐环境变量然后重新检测环境...''');
    }

    notifyListeners();
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

  /// 重置所有环境参数
  void resetEnv(Function action) {
    gitRoot = "";
    flutterRoot = "";
    adbRoot = "";
    androidSdkRoot = "";
    javaRoot = "";
    workSpaceRoot = "";
    envs.clear();
    notifyListeners();
    action();
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
