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

  EnvCheckResultEntity({required this.envPath, required this.envName});

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.write("envName=$envName;");
    sb.write("envPath=$envPath;");
    sb.write("envCheckResult=$envCheckResult;");
    return sb.toString();
  }
}
