import 'package:shared_preferences/shared_preferences.dart';

class SpConst {
  static const String envGitKey = "envGitKey";
  static const String envFlutterKey = "envFlutterKey";
  static const String envAdbKey = "envAdbKey";
  static const String envJavaKey = "envJavaKey";
  static const String envAndroidKey = "envAndroidKey";
  static const String envWorkspaceRootKey = "envWorkspaceRootKey";
  static const String isEnvChecked = "isEnvChecked";
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
