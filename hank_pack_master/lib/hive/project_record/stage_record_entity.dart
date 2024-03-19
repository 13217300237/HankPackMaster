import 'package:hive/hive.dart';

part 'stage_record_entity.g.dart';

/// 任务阶段
@HiveType(typeId: 8)
class StageRecordEntity {
  @HiveField(1)
  String? name; // 阶段名称

  @HiveField(2)
  int? costTime; // 执行时长(毫秒)

  @HiveField(3)
  String? resultStr; // 执行结果

  @HiveField(4)
  String? fullLog; // 执行全量日志

  @HiveField(5)
  bool? success; // 成功/失败

  StageRecordEntity({
    required this.name,
    this.costTime,
    this.resultStr,
    this.fullLog,
  });
}
