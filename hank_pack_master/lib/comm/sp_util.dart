import 'package:shared_preferences/shared_preferences.dart';

class SpConst {
  static const String envGitKey = "envGitKey";
  static const String envFlutterKey = "envFlutterKey";
  static const String envAdbKey = "envAdbKey";
  static const String envJavaKey = "envJavaKey";
  static const String envAndroidKey = "envAndroidKey";
  static const String envWorkspaceRootKey = "envWorkspaceRootKey";
  static const String isEnvChecked = "isEnvChecked";

  static const String stageTaskExecuteMaxPeriod = "stageTaskExecuteMaxPeriod"; // 一个阶段任务的单次最大可执行时间（秒）
  static const String stageTaskExecuteMaxRetryTimes = "stageTaskExecuteMaxRetryTimes";

  static const String pgyApiKey = "pgyApiKey"; // 蒲公英平台的apiKey
}

class SpUtil {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> putValue<T>(String key, T value) async {
    if (_prefs == null) {
      await init();
    }

    if (value is int) {
      return await _prefs!.setInt(key, value);
    } else if (value is double) {
      return await _prefs!.setDouble(key, value);
    } else if (value is bool) {
      return await _prefs!.setBool(key, value);
    } else if (value is String) {
      return await _prefs!.setString(key, value);
    } else if (value is List<String>) {
      return await _prefs!.setStringList(key, value);
    } else {
      return false;
    }
  }

  static T? getValue<T>(String key) {
    if (_prefs == null) {
      throw Exception("SP has not been initialized");
    }

    dynamic value = _prefs!.get(key);

    if (value is T) {
      return value;
    } else {
      return null;
    }
  }
}
