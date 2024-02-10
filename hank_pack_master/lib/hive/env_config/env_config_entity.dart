import 'package:hive/hive.dart';

part 'env_config_entity.g.dart';

@HiveType(typeId: 0x12137)
class EnvConfigEntity {
  @HiveField(0x01)
  late String envName;

  @HiveField(0x02)
  late String envValue;

  EnvConfigEntity(this.envName, this.envValue);
}
