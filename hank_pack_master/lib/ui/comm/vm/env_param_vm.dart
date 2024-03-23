import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:hank_pack_master/comm/toast_util.dart';

import '../../../comm/hwobs/obs_client.dart';
import '../../../comm/net/net_util.dart';
import '../../../comm/str_const.dart';
import '../../../hive/env_config/env_config_entity.dart';
import '../../../hive/env_config/env_config_operator.dart';
import '../../../hive/env_group/env_group_operator.dart';

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
    // 判断入参值和当前存储的值是否相同，如果相同，则不执行任何

    switch (title) {
      case "git":
        if (needToOverride || gitRoot.isEmpty) {
          if (gitRoot != value) {
            gitRoot = value;
            ToastUtil.showPrettyToast("默认 $title 环境已设置为:$value");
          }
        }
        break;
      case "flutter":
        if (needToOverride || flutterRoot.isEmpty) {
          if (flutterRoot != value) {
            flutterRoot = value;
            ToastUtil.showPrettyToast("默认 $title 环境已设置为:$value");
          }
        }
        break;
      case "adb":
        if (needToOverride || adbRoot.isEmpty) {
          if (adbRoot != value) {
            adbRoot = value;
            ToastUtil.showPrettyToast("默认 $title 环境已设置为:$value");
          }
        }

        break;
      case "android":
        if (needToOverride || androidSdkRoot.isEmpty) {
          if (androidSdkRoot != value) {
            androidSdkRoot = value;
            ToastUtil.showPrettyToast("默认 $title 环境已设置为:$value");
          }
        }

        break;
      case "java":
        if (needToOverride || javaRoot.isEmpty) {
          if (javaRoot != value) {
            javaRoot = value;
            ToastUtil.showPrettyToast("默认 $title 环境已设置为:$value");
          }
        }
        break;
      case "workSpaceRoot":
        if (needToOverride || workSpaceRoot.isEmpty) {
          if (workSpaceRoot != value) {
            workSpaceRoot = value;
            ToastUtil.showPrettyToast("默认 $title 环境已设置为:$value");
          }
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

  String getEnv(String title) {
    switch (title) {
      case "git":
        return gitRoot;
      case "flutter":
        return flutterRoot;
      case "adb":
        return adbRoot;
      case "android":
        return androidSdkRoot;
      case "java":
        return javaRoot;
      case "workSpaceRoot":
        return workSpaceRoot;
    }
    return "";
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

  set javaRoot(String javaPath) {
    EnvConfigOperator.insertOrUpdate(
        EnvConfigEntity(Const.envJavaKey, javaPath));
    notifyListeners();
  }

  String get workSpaceRoot =>
      EnvConfigOperator.searchEnvValue(Const.envWorkspaceRootKey);

  set workSpaceRoot(String r) {
    EnvConfigOperator.insertOrUpdate(
        EnvConfigEntity(Const.envWorkspaceRootKey, r));
    notifyListeners();
  }

  String isAndroidEnvOk() {
    if (workSpaceRoot.isEmpty) {
      return '工作空间未设置';
    }

    if (androidSdkRoot.isEmpty) {
      return '安卓SDK未设置';
    }

    if (pgyApiKey.isEmpty) {
      return 'pgy未设置';
    }

    return '';
  }

  TextEditingController stageTaskExecuteMaxPeriodController =
      TextEditingController();

  String get stageTaskExecuteMaxPeriod =>
      EnvConfigOperator.searchEnvValue(Const.stageTaskExecuteMaxPeriod);

  /// [maxPeriod] 单位为分钟
  set stageTaskExecuteMaxPeriod(String maxPeriod) {
    EnvConfigOperator.insertOrUpdate(
        EnvConfigEntity(Const.stageTaskExecuteMaxPeriod, maxPeriod));
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
    obsInit();
    notifyListeners();
  }

  /// obsAccessKey
  TextEditingController obsAccessKeyController = TextEditingController();

  String get obsAccessKey =>
      EnvConfigOperator.searchEnvValue(Const.obsAccessKey);

  set obsAccessKey(String v) {
    EnvConfigOperator.insertOrUpdate(EnvConfigEntity(Const.obsAccessKey, v));
    obsInit();
    notifyListeners();
  }

  /// obsSecretKey
  TextEditingController obsSecretKeyController = TextEditingController();

  String get obsSecretKey =>
      EnvConfigOperator.searchEnvValue(Const.obsSecretKey);

  set obsSecretKey(String v) {
    EnvConfigOperator.insertOrUpdate(EnvConfigEntity(Const.obsSecretKey, v));
    obsInit();
    notifyListeners();
  }

  /// obsBucketName
  TextEditingController obsBucketNameController = TextEditingController();

  String get obsBucketName =>
      EnvConfigOperator.searchEnvValue(Const.obsBucketName);

  set obsBucketName(String v) {
    EnvConfigOperator.insertOrUpdate(EnvConfigEntity(Const.obsBucketName, v));
    obsInit();
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

  void initComboBox(
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

  void obsInit() {
    OBSClient.init(
      ak: EnvConfigOperator.searchEnvValue(Const.obsAccessKey),
      sk: EnvConfigOperator.searchEnvValue(Const.obsSecretKey),
      domain: EnvConfigOperator.searchEnvValue(Const.obsEndPoint),
      bucketName: EnvConfigOperator.searchEnvValue(Const.obsBucketName),
    );
  }

  void init() {
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

    notifyListeners();
  }

  // 用combox替换输入框
  List<String> executePeriodList = ["10", "20", "30", "40"]; // 每次最大可执行时间
  List<String> executeTimes = ["2", "3", "4", "5", "6", "7"]; // 每次最大可执行时间

  void clearEnvGroupBox() {
    EnvGroupOperator.clear();
    notifyListeners();
  }

  bool get xGateState => _xGateState;

  bool _xGateState = false;

  bool get needShowXGateTag => _needShowXGateTag;

  bool _needShowXGateTag = false;

  StreamSubscription? _streamSubscription;

  void startXGateListen() {
    _streamSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // debugPrint("网络发生变化 ${result.name}");
      NetUtil.getInstance().checkCodehub(
        onXGateConnect: (b) {
          _xGateState = b;

          // 在网络变化过程中，如果出现了脸上内网的情况，就说明此tag有必要显示
          if (b == true) {
            _needShowXGateTag = true;
          }

          notifyListeners();
        },
      );
    });
  }

  void cancelXGateListen() {
    _streamSubscription?.cancel();
  }
}
