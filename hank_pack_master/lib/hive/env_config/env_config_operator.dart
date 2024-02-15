import 'package:hank_pack_master/hive/env_config/env_config_entity.dart';
import 'package:hive/hive.dart';

class EnvConfigOperator {
  static const String _boxName = "envConfigDbV2";

  static Future<void> openBox() async {
    Hive.registerAdapter(EnvConfigEntityAdapter(), override: true);
    await Hive.openBox<EnvConfigEntity>(_boxName);
  }

  static Box<EnvConfigEntity>? _box;

  static _initBox() {
    _box ??= Hive.box<EnvConfigEntity>(_boxName);
  }

  static void insertOrUpdate(EnvConfigEntity entity) {
    _initBox();
    int index =
        _box!.values.toList().indexWhere((p) => p.envName == entity.envName);

    if (index != -1) {
      _box!.putAt(index, entity); // 执行更新操作
    } else {
      _box!.add(entity); // 执行插入操作
    }
  }

  static void delete(EnvConfigEntity entity) {
    _initBox();
    int index =
        _box!.values.toList().indexWhere((p) => p.envName == entity.envName);

    if (index != -1) {
      _box!.deleteAt(index); // 执行删除操作
    } else {
      throw Exception("找不到该条记录，无法删除");
    }
  }

  static EnvConfigEntity? _search(String name) {
    _initBox();
    try {
      return _box!.values.firstWhere((person) => person.envName == name);
    } catch (e) {
      return null;
    }
  }

  static String searchEnvValue(String name) {
    var searchRes = _search(name);
    if (searchRes != null) {
      return searchRes.envValue;
    } else {
      return "";
    }
  }
}
