import 'package:hank_pack_master/hive/project_record/package_setting_entity.dart';
import 'package:hive/hive.dart';

part 'project_record_entity.g.dart';

/// 打包任务实体类
/// 概念：当设定一个 gitUrl 和 branch 时，一个 projectRecord就已经确定，后续它的打包结果，都会依附于此projectRecord
@HiveType(typeId: 2)
class ProjectRecordEntity {
  @HiveField(1)
  late String projectName;

  @HiveField(2)
  late String gitUrl;

  @HiveField(3)
  late String branch;

  @HiveField(4)
  late bool preCheckOk; // 是否已预检成功

  /// [已废弃]
  @HiveField(5)
  List<String>? assembleOrders; // TODO  listString的存储方式存在bug

  @HiveField(6)
  List<String>? jobHistory;

  /// 是否处在工作中...
  @HiveField(7)
  bool? jobRunning;

  @HiveField(8)
  String? projectDesc;

  @HiveField(9)
  PackageSetting? activeSetting; // 激活阶段的配置

  @HiveField(10)
  PackageSetting? packageSetting; // 打包阶段的配置

  @HiveField(11)
  PackageSetting? fastUploadSetting; // 快速上传阶段的配置

  @HiveField(12)
  String? assembleOrdersStr; // 换个方式存储可用变体

  List<String> get assembleOrderList {
    List<String> list = [];
    if (assembleOrdersStr == null) return list;

    var split = assembleOrdersStr!.split("\n");
    for (var e in split) {
      if (e.isNotEmpty) {
        list.add(e.trim());
      }
    }
    return list;
  }

  /// 临时字段，不用存数据库
  /// 传递给工坊的对象，包含了打包所需的所有参数
  PackageSetting? setting;

  double processValue = 0;

  // 用一个字段保存apk路径(只有上传失败的任务才会短暂保存这个值)
  String? apkPath;

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
