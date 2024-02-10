import 'package:hive/hive.dart';

part 'project_record_entity.g.dart';

/// 打包任务实体类
/// 概念：当设定一个 gitUrl 和 branch 时，一个 projectRecord就已经确定，后续它的打包结果，都会依附于此projectRecord
@HiveType(typeId: 0x12138)
class ProjectRecordEntity {
  @HiveField(0x01)
  late String gitUrl;

  @HiveField(0x02)
  late String branch;

  ProjectRecordEntity(this.gitUrl, this.branch);
}
