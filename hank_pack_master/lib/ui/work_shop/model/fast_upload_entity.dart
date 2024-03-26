import 'dart:convert';
import 'dart:io';

/// 上传阶段遇到问题，会产生这么一个对象
class UploadResultEntity {
  String apkPath;
  String errMsg;

  UploadResultEntity({
    required this.apkPath,
    required this.errMsg,
  });

  Map<String, dynamic> toJson() {
    return {
      "apkPath": apkPath,
      "errMsg": errMsg,
    };
  }

  /// 上传的对象是否合法
  bool correct() =>
      apkPath.isNotEmpty && File(apkPath).existsSync() && errMsg.isNotEmpty;

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory UploadResultEntity.fromJson(Map<String, dynamic> data) {
    return UploadResultEntity(
      apkPath: data['apkPath'],
      errMsg: data['errMsg'],
    );
  }

  factory UploadResultEntity.fromJsonString(String jsonString) {
    return UploadResultEntity.fromJson(jsonDecode(jsonString));
  }
}
