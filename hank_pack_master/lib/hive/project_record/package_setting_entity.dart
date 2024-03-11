import 'package:hive/hive.dart';

import 'upload_platforms.dart';
import '../env_group/env_check_result_entity.dart';

part 'package_setting_entity.g.dart';

/// 打包作业配置
@HiveType(typeId: 5)
class PackageSetting {
  @HiveField(1)
  String? appUpdateLog;

  @HiveField(2)
  String? apkLocation;

  @HiveField(3)
  String? selectedOrder;

  @HiveField(4)
  UploadPlatform? selectedUploadPlatform;

  @HiveField(5)
  List<String>? mergeBranchList;

  @HiveField(6)
  EnvCheckResultEntity? jdk; // 当前使用的jdk版本

  PackageSetting({
    this.appUpdateLog,
    this.apkLocation,
    this.selectedOrder,
    this.selectedUploadPlatform,
    this.jdk,
    this.mergeBranchList,
  });

  String readyToPackage() {
    if (jdk == null) {
      return "jdk必必须指定";
    }
    if (selectedOrder == null || selectedOrder!.isEmpty) {
      return "打包命令必须选择";
    }
    if (selectedUploadPlatform == null) {
      return "上传方式必须选择";
    }
    return '';
  }

  String readyToActive() {
    if (jdk == null) {
      return "jdk必必须指定";
    }
    return '';
  }

  String readyOnlyPlatform() {
    if (selectedUploadPlatform == null) {
      return "上传方式必须选择";
    }
    return '';
  }
}
