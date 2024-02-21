import 'package:hive/hive.dart';

import '../../comm/upload_platforms.dart';

part 'project_record_entity.g.dart';

/// 打包任务实体类
/// 概念：当设定一个 gitUrl 和 branch 时，一个 projectRecord就已经确定，后续它的打包结果，都会依附于此projectRecord
@HiveType(typeId: 2)
class ProjectRecordEntity {
  @HiveField(0x04)
  late String projectName;

  @HiveField(0x01)
  late String gitUrl;

  @HiveField(0x02)
  late String branch;

  @HiveField(0x03)
  late bool preCheckOk; // 是否已预检成功

  @HiveField(0x05)
  List<String>? assembleOrders;

  @HiveField(0x06)
  List<String>? jobHistory;

  /// 是否处在工作中...
  @HiveField(0x07)
  bool? jobRunning;

  @HiveField(0x08)
  String? projectDesc;

  /// 临时字段，不用存数据库
  /// 传递给工坊的对象，包含了打包所需的所有参数
  PackageSetting? setting;

  ProjectRecordEntity(
    this.gitUrl,
    this.branch,
    this.projectName,
    this.projectDesc, {
    this.preCheckOk = false,
    this.jobRunning = false,
    this.assembleOrders,
    this.jobHistory,
  });

  @override
  String toString() {
    return "$projectName \n $gitUrl \n  $branch";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectRecordEntity &&
        other.gitUrl == gitUrl &&
        other.branch == branch;
  }

  @override
  int get hashCode => branch.hashCode ^ gitUrl.hashCode;
}

class PackageSetting {
  String? appDescStr;
  String? appUpdateStr;
  String? apkLocation;
  String? selectedOrder;
  UploadPlatform? selectedUploadPlatform;

  PackageSetting({
    this.appDescStr,
    this.appUpdateStr,
    this.apkLocation,
    this.selectedOrder,
    this.selectedUploadPlatform,
  });

  String ready() {
    if (selectedOrder == null || selectedOrder!.isEmpty) {
      return "打包命令必须选择";
    }
    if (selectedUploadPlatform == null) {
      return "上传方式必须选择";
    }
    return '';
  }
}
