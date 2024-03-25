import 'dart:convert';

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
