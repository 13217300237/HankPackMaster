import 'package:hive/hive.dart';

import 'comm_entity_type_set.dart';

part 'env_config_entity.g.dart';

@HiveType(typeId: envConfigClassType)
class EnvConfigEntity {
  @HiveField(envConfigEnvNameType)
  late String envName;

  @HiveField(envConfigEnvValueType)
  late String envValue;

  EnvConfigEntity(this.envName, this.envValue);
}
