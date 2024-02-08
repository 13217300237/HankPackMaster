import 'package:hank_pack_master/hive/project_record/project_record_type_set.dart';
import 'package:hive/hive.dart';

part 'project_record_entity.g.dart';

@HiveType(typeId: projectRecordClassType)
class ProjectRecordEntity {
  @HiveField(projectRecordGitUrlType)
  late String gitUrl;

  @HiveField(projectRecordBranchType)
  late String branch;

  ProjectRecordEntity(this.gitUrl, this.branch);
}
