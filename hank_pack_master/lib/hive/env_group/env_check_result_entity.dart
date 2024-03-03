import 'package:hive/hive.dart';

part 'env_check_result_entity.g.dart';

@HiveType(typeId: 4)
class EnvCheckResultEntity {
  @HiveField(1)
  late String envName;

  @HiveField(2)
  late String envPath;

  @HiveField(3)
  String? envCheckResult;

  EnvCheckResultEntity(
      {required this.envPath, required this.envName, this.envCheckResult});

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.writeln("envName=$envName;");
    sb.writeln("envPath=$envPath;");
    sb.writeln("envCheckResult=${envCheckResult?.trim()};");
    return sb.toString();
  }
}
