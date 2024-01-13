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
  Map<String,dynamic>? data;

  ReleaseResultEntity({this.code, this.message,this.data});

  ReleaseResultEntity.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'];
  }
}



class MyAppInfo {
  final String? buildKey;
  final String? buildType;
  final String? buildIsFirst;
  final String? buildIsLastest;
  final String? buildFileKey;
  final String? buildFileName;
  final String? buildFileSize;
  final String? buildName;
  final String? buildVersion;
  final String? buildVersionNo;
  final String? buildBuildVersion;
  final String? buildIdentifier;
  final String? buildIcon;
  final String? buildDescription;
  final String? buildUpdateDescription;
  final String? buildScreenshots;
  final String? buildShortcutUrl;
  final String? buildCreated;
  final String? buildUpdated;
  final String? buildQRCodeURL;

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
  });

  factory MyAppInfo.fromJson(Map<String,dynamic> data) {

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
    );
  }
}
