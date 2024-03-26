import 'dart:convert';

import 'package:hive/hive.dart';

part 'job_result_entity.g.dart';

/// 作业结果实体类
@HiveType(typeId: 9)
class JobResultEntity {
  @HiveField(1)
  String? uploadPlatform;
  @HiveField(2)
  String? buildKey;
  @HiveField(3)
  String? buildType;
  @HiveField(4)
  String? buildIsFirst;
  @HiveField(5)
  String? buildIsLastest;
  @HiveField(6)
  String? buildFileKey;
  @HiveField(7)
  String? buildFileName;
  @HiveField(8)
  String? buildFileSize;
  @HiveField(9)
  String? buildName;
  @HiveField(10)
  String? buildVersion;
  @HiveField(11)
  String? buildVersionNo;
  @HiveField(12)
  String? buildBuildVersion;
  @HiveField(13)
  String? buildIdentifier;
  @HiveField(14)
  String? buildIcon;
  @HiveField(15)
  String? buildDescription;
  @HiveField(16)
  String? buildUpdateDescription;
  @HiveField(17)
  String? buildScreenshots;
  @HiveField(18)
  String? buildShortcutUrl;
  @HiveField(19)
  String? buildCreated;
  @HiveField(20)
  String? buildUpdated;
  @HiveField(21)
  String? buildQRCodeURL;
  @HiveField(22)
  String? errMessage; // 现在用错误message表示整个错误

  @HiveField(23)
  String? errCode; // 错误码，暂未用到

  @HiveField(24)
  List<String>? assembleOrders;

  @HiveField(25)
  String? apkPath; // apk产物所在位置

  JobResultEntity({
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
    this.errCode,
    this.errMessage,
    this.assembleOrders,
    this.apkPath,
  });

  factory JobResultEntity.fromJson(Map<String, dynamic> data) {
    return JobResultEntity(
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
      errCode: data['errCode'],
      errMessage: data['errMessage'],
      assembleOrders: (data['assembleOrders'] ?? []).cast<String>(),
      apkPath: data['apkPath'],
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
      'errCode': errCode,
      'errMessage': errMessage,
      'assembleOrders': assembleOrders,
      'apkPath': apkPath,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory JobResultEntity.fromJsonString(String jsonString) {
    return JobResultEntity.fromJson(jsonDecode(jsonString));
  }
}
