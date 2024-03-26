import 'package:hank_pack_master/hive/project_record/package_setting_entity.dart';
import 'package:hank_pack_master/hive/project_record/stage_record_entity.dart';
import 'package:hive/hive.dart';

part 'job_history_entity.g.dart';

/// 打包作业配置
@HiveType(typeId: 7)
class JobHistoryEntity {
  @HiveField(1)
  bool? success;

  @HiveField(3)
  int? buildTime; // 构建时间

  // 作业历史内容,保存的是json，可能是 JobResultEntity 的json串，也有可能是不规律的错误日志
  @HiveField(2)
  String? historyContent;

  @HiveField(4)
  bool? hasRead; // 是否已读

  @HiveField(5)
  PackageSetting? jobSetting; // 作业配置

  @HiveField(6)
  List<StageRecordEntity>? stageRecordList; // 阶段执行日志

  @HiveField(7)
  String? taskName; // 可能是项目激活，项目打包，以及 产物快速上传

  /// 临时字段，不必存到数据库
  String? projectName;
  String? gitUrl;
  String? branchName;
  String? projectDesc;

  JobHistoryEntity({
    required this.buildTime,
    required this.success,
    required this.historyContent,
    required this.hasRead,
    required this.jobSetting,
    this.stageRecordList,
    this.taskName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobHistoryEntity &&
        other.gitUrl == gitUrl &&
        other.branchName == branchName;
  }

  @override
  int get hashCode => branchName.hashCode ^ gitUrl.hashCode;
}
