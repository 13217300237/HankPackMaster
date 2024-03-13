import 'package:hive/hive.dart';
part 'job_history_entity.g.dart';

/// 打包作业配置
@HiveType(typeId: 7)
class JobHistoryEntity {
  @HiveField(1)
  bool? success;

  @HiveField(3)
  int? buildTime; // 构建时间

  @HiveField(2)
  String? historyContent; // 构建时间

  JobHistoryEntity({
    required this.buildTime,
    required this.success,
    required this.historyContent,
  });
}
