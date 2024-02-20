import 'package:flutter/cupertino.dart';

import '../../../comm/str_const.dart';
import '../../../hive/env_config/env_config_entity.dart';
import '../../../hive/env_config/env_config_operator.dart';

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

  ///
  /// [title]
  /// [value]
  /// [needToOverride] 是否需要覆盖写入，false 时，只会给当前值为空时赋值，true则无条件赋值
  ///
  void setEnv(
    String title,
    String value, {
    required bool needToOverride,
  }) {
    switch (title) {
      case "git":
        if (needToOverride || gitRoot.isEmpty) {
          gitRoot = value;
        }
        break;
      case "flutter":
        if (needToOverride || flutterRoot.isEmpty) {
          flutterRoot = value;
        }
        break;
      case "adb":
        if (needToOverride || adbRoot.isEmpty) {
          adbRoot = value;
        }

        break;
      case "android":
        if (needToOverride || androidSdkRoot.isEmpty) {
          androidSdkRoot = value;
        }

        break;
      case "java":
        if (needToOverride || javaRoot.isEmpty) {
          javaRoot = value;
        }
        break;
      case "workSpaceRoot":
        if (needToOverride || workSpaceRoot.isEmpty) {
          workSpaceRoot = value;
        }
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

  String get gitRoot => EnvConfigOperator.searchEnvValue(Const.envGitKey);

  set gitRoot(String r) {
    EnvConfigOperator.insertOrUpdate(EnvConfigEntity(Const.envGitKey, r));
    notifyListeners();
  }

  String get flutterRoot =>
      EnvConfigOperator.searchEnvValue(Const.envFlutterKey);

  set flutterRoot(String r) {
    EnvConfigOperator.insertOrUpdate(EnvConfigEntity(Const.envFlutterKey, r));
    notifyListeners();
  }

  String get adbRoot => EnvConfigOperator.searchEnvValue(Const.envAdbKey);

  set adbRoot(String r) {
    EnvConfigOperator.insertOrUpdate(EnvConfigEntity(Const.envAdbKey, r));
    notifyListeners();
  }

  String get androidSdkRoot =>
      EnvConfigOperator.searchEnvValue(Const.envAndroidKey);

  set androidSdkRoot(String r) {
    EnvConfigOperator.insertOrUpdate(EnvConfigEntity(Const.envAndroidKey, r));
    notifyListeners();
  }

  String get javaRoot => EnvConfigOperator.searchEnvValue(Const.envJavaKey);

  set javaRoot(String r) {
    EnvConfigOperator.insertOrUpdate(EnvConfigEntity(Const.envJavaKey, r));
    notifyListeners();
  }

  String get workSpaceRoot =>
      EnvConfigOperator.searchEnvValue(Const.envWorkspaceRootKey);

  set workSpaceRoot(String r) {
    EnvConfigOperator.insertOrUpdate(
        EnvConfigEntity(Const.envWorkspaceRootKey, r));
    notifyListeners();
  }

  bool isAndroidEnvOk() {
    if (workSpaceRoot.isEmpty) {
      return false;
    }

    if (androidSdkRoot.isEmpty) {
      return false;
    }

    if (pgyApiKey.isEmpty) {
      return false;
    }

    return true;
  }

  TextEditingController stageTaskExecuteMaxPeriodController =
      TextEditingController();

  String get stageTaskExecuteMaxPeriod =>
      EnvConfigOperator.searchEnvValue(Const.stageTaskExecuteMaxPeriod);

  set stageTaskExecuteMaxPeriod(String max) {
    EnvConfigOperator.insertOrUpdate(
        EnvConfigEntity(Const.stageTaskExecuteMaxPeriod, max));
    notifyListeners();
  }

  TextEditingController stageTaskExecuteMaxRetryTimesController =
      TextEditingController();

  String get stageTaskExecuteMaxRetryTimes =>
      EnvConfigOperator.searchEnvValue(Const.stageTaskExecuteMaxRetryTimes);

  set stageTaskExecuteMaxRetryTimes(String max) {
    EnvConfigOperator.insertOrUpdate(
        EnvConfigEntity(Const.stageTaskExecuteMaxRetryTimes, max));
    notifyListeners();
  }

  /// PGY apikey
  TextEditingController pgyApiKeyController = TextEditingController();

  String get pgyApiKey => EnvConfigOperator.searchEnvValue(Const.pgyApiKey);

  set pgyApiKey(String v) {
    EnvConfigOperator.insertOrUpdate(EnvConfigEntity(Const.pgyApiKey, v));
    notifyListeners();
  }

  /// obsEndPoint
  TextEditingController obsEndPointController = TextEditingController();

  String get obsEndPoint => EnvConfigOperator.searchEnvValue(Const.obsEndPoint);

  set obsEndPoint(String v) {
    EnvConfigOperator.insertOrUpdate(EnvConfigEntity(Const.obsEndPoint, v));
    notifyListeners();
  }

  /// obsAccessKey
  TextEditingController obsAccessKeyController = TextEditingController();

  String get obsAccessKey =>
      EnvConfigOperator.searchEnvValue(Const.obsAccessKey);

  set obsAccessKey(String v) {
    EnvConfigOperator.insertOrUpdate(EnvConfigEntity(Const.obsAccessKey, v));
    notifyListeners();
  }

  /// obsSecretKey
  TextEditingController obsSecretKeyController = TextEditingController();

  String get obsSecretKey =>
      EnvConfigOperator.searchEnvValue(Const.obsSecretKey);

  set obsSecretKey(String v) {
    EnvConfigOperator.insertOrUpdate(EnvConfigEntity(Const.obsSecretKey, v));
    notifyListeners();
  }

  /// obsBucketName
  TextEditingController obsBucketNameController = TextEditingController();

  String get obsBucketName =>
      EnvConfigOperator.searchEnvValue(Const.obsBucketName);

  set obsBucketName(String v) {
    EnvConfigOperator.insertOrUpdate(EnvConfigEntity(Const.obsBucketName, v));
    notifyListeners();
  }

  void initTextController(
    TextEditingController editTextController,
    String Function() get,
    Function(String) set,
  ) {
    editTextController.text = get();
    editTextController.addListener(() {
      if (editTextController.text.isNotEmpty) {
        set(editTextController.text);
      }
    });
  }

  void init() {
    initTextController(
        stageTaskExecuteMaxPeriodController,
        () => stageTaskExecuteMaxPeriod,
        (String s) => stageTaskExecuteMaxPeriod = s);

    initTextController(
        stageTaskExecuteMaxRetryTimesController,
        () => stageTaskExecuteMaxRetryTimes,
        (String s) => stageTaskExecuteMaxRetryTimes = s);

    initTextController(
        pgyApiKeyController, () => pgyApiKey, (String s) => pgyApiKey = s);

    initTextController(obsEndPointController, () => obsEndPoint,
        (String s) => obsEndPoint = s);

    initTextController(obsAccessKeyController, () => obsAccessKey,
        (String s) => obsAccessKey = s);

    initTextController(obsSecretKeyController, () => obsSecretKey,
        (String s) => obsSecretKey = s);

    initTextController(obsBucketNameController, () => obsBucketName,
            (String s) => obsBucketName = s);
  }
}
