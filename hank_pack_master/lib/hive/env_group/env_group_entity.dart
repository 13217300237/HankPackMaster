import 'package:hive/hive.dart';

import 'env_check_result_entity.dart';

part 'env_group_entity.g.dart';

@HiveType(typeId: 3)
class EnvGroupEntity {
  @HiveField(1)
  late String envGroupName;

  @HiveField(2)
  List<EnvCheckResultEntity>? envValue;

  EnvGroupEntity({required this.envGroupName});

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.writeln("envGroupName=>$envGroupName");

    envValue?.forEach((e) {
      sb.writeln("[");
      sb.writeln(e.toString());
      sb.writeln("]");
    });

    return sb.toString();
  }
}
