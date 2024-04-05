import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/toast_util.dart';
import 'package:hank_pack_master/hive/project_record/project_record_operator.dart';

import '../../../comm/hwobs/obs_client.dart';
import '../../../comm/net/net_util.dart';
import '../../../comm/str_const.dart';
import '../../../hive/env_config/env_config_entity.dart';
import '../../../hive/env_config/env_config_operator.dart';
import '../../../hive/env_group/env_group_operator.dart';

class EnvParamVm extends ChangeNotifier {
  /// 环境有问题时的错误提示
  final Map<String, String> envGuide = {
    "git": "如果下方存在可选的git路径，请手动选择一个作为git默认路径, \n如果下方不存在，请手动下载并安装git,并重启此软件",
    "adb": "如果下方存在可选的adb可执行文件路径，请手动选择一个作为adb默认路径, \n如果下方不存在，请手动下载并安装AndroidSdk,并重启此软件",
    "java": "如果下方存在可选的java可执行文件路径，请手动选择一个作为java默认路径, \n如果下方不存在，请手动下载并安装JDK,并重启此软件",
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

  List<String> isEnvOk() {
    List<String> errList = [];

    if (javaRoot.isEmpty) {
      errList.add('Jdk未设置');
    }
    if (gitRoot.isEmpty) {
      errList.add('git未设置');
    }
    if (adbRoot.isEmpty) {
      errList.add('adb未设置');
    }
    if (workSpaceRoot.isEmpty) {
      errList.add('工作空间未设置');
    }
    if (androidSdkRoot.isEmpty) {
      errList.add('安卓SDK未设置');
    }
    if (pgyApiKey.isEmpty) {
      errList.add('pgy key 未设置');
    }
    if (obsEndPoint.isEmpty) {
      errList.add('obs endpoint 未设置');
    }
    if (obsBucketName.isEmpty) {
      errList.add('obs bucketName 未设置');
    }
    if (obsSecretKey.isEmpty) {
      errList.add('obs sk 未设置');
    }
    if (obsAccessKey.isEmpty) {
      errList.add('obs ak 未设置');
    }

    return errList;
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

  String get stageTaskExecuteMaxRetryCount =>
      EnvConfigOperator.searchEnvValue(Const.stageTaskExecuteMaxRetryTimes);

  set stageTaskExecuteMaxRetryCount(String max) {
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

    if (obsExpiredDays.isEmpty) {
      obsExpiredDays = obsExpiredDaysValues[0].toString();
    }
    if (stageTaskExecuteMaxRetryCount.isEmpty) {
      stageTaskExecuteMaxRetryCount = stageTaskExecuteMaxRetryCountValues[0];
    }
    if (stageTaskExecuteMaxPeriod.isEmpty) {
      stageTaskExecuteMaxPeriod = stageTaskExecuteMaxPeriodValues[0];
    }

    notifyListeners();
  }

  // 用combox替换输入框
  List<String> stageTaskExecuteMaxPeriodValues = [
    "10",
    "20",
    "30",
    "40"
  ]; // 每次最大可执行时间
  List<String> stageTaskExecuteMaxRetryCountValues = [
    "2",
    "3",
    "4",
    "5",
    "6",
    "7"
  ]; // 每次最大可执行时间

  List<int> obsExpiredDaysValues = [
    7,
    30,
    60,
    90,
    360,
    3600,
  ]; // obs文件保存天数
  String get obsExpiredDays {
    return EnvConfigOperator.searchEnvValue(Const.obsExpiredDays);
  }

  set obsExpiredDays(String days) {
    EnvConfigOperator.insertOrUpdate(
        EnvConfigEntity(Const.obsExpiredDays, days));
    notifyListeners();
  }

  void clearEnvGroupBox() {
    EnvGroupOperator.clear();
    EnvConfigOperator.clear();
    notifyListeners();
  }

  bool get xGateState => _xGateState;

  bool _xGateState = false;

  String _networkName = '';
  Color _networkColor = Colors.teal;

  Color get networkColor => _networkColor;

  String get networkName => _networkName;

  bool get needShowXGateTag => _needShowXGateTag;

  bool _needShowXGateTag = false;

  StreamSubscription? _streamSubscription;

  void setNetState(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.bluetooth:
        _networkName = '蓝牙';
        _networkColor = Colors.blue;
        break;
      case ConnectivityResult.wifi:
        _networkName = 'Wifi';
        _networkColor = Colors.orange;
        break;
      case ConnectivityResult.ethernet:
        _networkName = '以太网';
        _networkColor = Colors.green;
        break;
      case ConnectivityResult.mobile:
        _networkName = '手机网络';
        _networkColor = Colors.teal;
        break;
      case ConnectivityResult.none:
        _networkName = '无网络';
        _networkColor = Colors.red;
        break;
      case ConnectivityResult.vpn:
        _networkName = 'VPN';
        _networkColor = Colors.magenta;
        break;
      case ConnectivityResult.other:
        _networkName = '其他';
        _networkColor = Colors.orange.normal;
        break;
    }
  }

  void startXGateListen({required Function showFastUploadDialogFunc}) {
    _streamSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setNetState(result);
      checkCodehub(showFastUploadDialogFunc: showFastUploadDialogFunc);
    });
  }

  void checkCodehub({required Function showFastUploadDialogFunc}) {
    NetUtil.getInstance().checkCodehub(
      onXGateConnect: (b) {
        _xGateState = b;

        // 只有在xGate断开的情况下才弹出
        if (_xGateState == false) {
          if (ProjectRecordOperator.findFastUploadTaskList().isNotEmpty) {
            showFastUploadDialogFunc();
          }
        }
        // 在网络变化过程中，如果出现了脸上内网的情况，就说明此tag有必要显示
        if (b == true) {
          _needShowXGateTag = true;
        }

        notifyListeners();
      },
    );
  }

  void checkFastUploadTaskExists({required Function showFastUploadDialogFunc}) {
    bool s = ProjectRecordOperator.findFastUploadTaskList().isNotEmpty;

    if (s == true) {
      showFastUploadDialogFunc.call();
    }
  }

  void cancelXGateListen() {
    _streamSubscription?.cancel();
  }

  /// 检查安卓环境是否就绪，如果没就绪，就弹出报告
  Future<List<String>> checkEnv() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return isEnvOk();
  }
}
