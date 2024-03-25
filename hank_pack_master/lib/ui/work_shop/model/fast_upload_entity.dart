import 'dart:convert';

class FastUploadEntity {
  String apkPath;
  String errMsg;

  FastUploadEntity({
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

  factory FastUploadEntity.fromJson(Map<String, dynamic> data) {
    return FastUploadEntity(
      apkPath: data['apkPath'],
      errMsg: data['errMsg'],
    );
  }

  factory FastUploadEntity.fromJsonString(String jsonString) {
    return FastUploadEntity.fromJson(jsonDecode(jsonString));
  }
}
