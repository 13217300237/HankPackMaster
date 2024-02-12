import 'package:hive/hive.dart';

part 'env_config_entity.g.dart';

@HiveType(typeId: 74)
class EnvConfigEntity {
  @HiveField(1)
  late String envName;

  @HiveField(2)
  late String envValue;

  EnvConfigEntity(this.envName, this.envValue);
}
