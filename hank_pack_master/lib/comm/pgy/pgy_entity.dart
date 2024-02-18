import 'dart:convert';


class PgyTokenEntity {
  int? code;
  String? message;
  Details? data;

  PgyTokenEntity({this.code, this.message, this.data});

  PgyTokenEntity.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = Details.fromJson(json['data']);
  }

  @override
  String toString() {
    return """
message = $message 
endpoint = ${data?.endpoint} 
xCosSecurityToken = ${data?.params?.xCosSecurityToken} 
signature = ${data?.params?.signature} 
key = ${data?.params?.key}""";
  }
}

class Details {
  Params? params;
  String? key;
  String? endpoint;

  Details({this.params, this.key, this.endpoint});

  Details.fromJson(Map<String, dynamic> json) {
    params = Params.fromJson(json['params']);
    key = json['key'];
    endpoint = json['endpoint'];
  }
}

class Params {
  String? signature;
  String? xCosSecurityToken;
  String? key;

  Params({this.signature, this.xCosSecurityToken, this.key});

  Params.fromJson(Map<String, dynamic> json) {
    signature = json['signature'];
    xCosSecurityToken = json['x-cos-security-token'];
    key = json['key'];
  }
}

class ReleaseResultEntity {
  int? code;
  String? message;
  Map<String, dynamic>? data;

  ReleaseResultEntity({this.code, this.message, this.data});

  ReleaseResultEntity.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'];
  }
}

class MyAppInfo {
  String? uploadPlatform;

  String? buildKey;
  String? buildType;
  String? buildIsFirst;
  String? buildIsLastest;
  String? buildFileKey;
  String? buildFileName;
  String? buildFileSize;
  String? buildName;
  String? buildVersion;
  String? buildVersionNo;
  String? buildBuildVersion;
  String? buildIdentifier;
  String? buildIcon;
  String? buildDescription;
  String? buildUpdateDescription;
  String? buildScreenshots;
  String? buildShortcutUrl;
  String? buildCreated;
  String? buildUpdated;
  String? buildQRCodeURL;

  MyAppInfo({
    this.buildKey,
    this.buildType,
    this.buildIsFirst,
    this.buildIsLastest,
    this.buildFileKey,
    this.buildFileName,
    this.buildFileSize,
    this.buildName,
    this.buildVersion,
    this.buildVersionNo,
    this.buildBuildVersion,
    this.buildIdentifier,
    this.buildIcon,
    this.buildDescription,
    this.buildUpdateDescription,
    this.buildScreenshots,
    this.buildShortcutUrl,
    this.buildCreated,
    this.buildUpdated,
    this.buildQRCodeURL,
    this.uploadPlatform,
  });

  factory MyAppInfo.fromJson(Map<String, dynamic> data) {
    return MyAppInfo(
      buildKey: data['buildKey'],
      buildType: data['buildType'],
      buildIsFirst: data['buildIsFirst'],
      buildIsLastest: data['buildIsLastest'],
      buildFileKey: data['buildFileKey'],
      buildFileName: data['buildFileName'],
      buildFileSize: data['buildFileSize'],
      buildName: data['buildName'],
      buildVersion: data['buildVersion'],
      buildVersionNo: data['buildVersionNo'],
      buildBuildVersion: data['buildBuildVersion'],
      buildIdentifier: data['buildIdentifier'],
      buildIcon: data['buildIcon'],
      buildDescription: data['buildDescription'],
      buildUpdateDescription: data['buildUpdateDescription'],
      buildScreenshots: data['buildScreenshots'],
      buildShortcutUrl: data['buildShortcutUrl'],
      buildCreated: data['buildCreated'],
      buildUpdated: data['buildUpdated'],
      buildQRCodeURL: data['buildQRCodeURL'],
      uploadPlatform: data['uploadPlatform'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buildKey': buildKey,
      'buildType': buildType,
      'buildIsFirst': buildIsFirst,
      'buildIsLastest': buildIsLastest,
      'buildFileKey': buildFileKey,
      'buildFileName': buildFileName,
      'buildFileSize': buildFileSize,
      'buildName': buildName,
      'buildVersion': buildVersion,
      'buildVersionNo': buildVersionNo,
      'buildBuildVersion': buildBuildVersion,
      'buildIdentifier': buildIdentifier,
      'buildIcon': buildIcon,
      'buildDescription': buildDescription,
      'buildUpdateDescription': buildUpdateDescription,
      'buildScreenshots': buildScreenshots,
      'buildShortcutUrl': buildShortcutUrl,
      'buildCreated': buildCreated,
      'buildUpdated': buildUpdated,
      'buildQRCodeURL': buildQRCodeURL,
      'uploadPlatform': uploadPlatform,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory MyAppInfo.fromJsonString(String jsonString) {
    return MyAppInfo.fromJson(jsonDecode(jsonString));
  }
}
