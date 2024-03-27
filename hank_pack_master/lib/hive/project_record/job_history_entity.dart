import 'dart:convert';

import 'package:hank_pack_master/hive/project_record/package_setting_entity.dart';
import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';
import 'package:hank_pack_master/hive/project_record/stage_record_entity.dart';
import 'package:hive/hive.dart';

import 'job_result_entity.dart';

part 'job_history_entity.g.dart';

/// 打包作业配置
@HiveType(typeId: 7)
class JobHistoryEntity {
  @HiveField(1)
  bool? success;

  @HiveField(3)
  int? buildTime; // 构建时间

  @HiveField(4)
  bool? hasRead; // 是否已读

  @HiveField(5)
  PackageSetting? jobSetting; // 作业配置

  @HiveField(6)
  List<StageRecordEntity>? stageRecordList; // 阶段执行日志

  @HiveField(7)
  String? taskName; // 可能是项目激活，项目打包，以及 产物快速上传

  @HiveField(8)
  JobResultEntity jobResultEntity; // 作业结果封装

  late ProjectRecordEntity parentRecord; // 工程实体的副本，果然不能用这个副本,至少不能保存到数据库

  @override
  String toString() {
    return jsonEncode({
      "success": "$success",
      "buildTime": "$buildTime",
      "hasRead": "$hasRead",
      "jobSetting": "$jobSetting",
      "stageRecordList": "$stageRecordList",
      "taskName": "$taskName",
      "jobResultEntity": "$jobResultEntity",
      "parentRecord": "$parentRecord",
    });
  }

  JobHistoryEntity({
    required this.buildTime,
    required this.success,
    required this.hasRead,
    required this.jobSetting,
    this.stageRecordList,
    this.taskName,
    required this.jobResultEntity,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobHistoryEntity && other.parentRecord == parentRecord;
  }

  @override
  int get hashCode => parentRecord.hashCode;
}
