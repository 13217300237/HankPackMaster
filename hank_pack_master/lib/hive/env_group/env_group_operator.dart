import 'package:hive/hive.dart';

import 'env_group_entity.dart';

class EnvGroupOperator {
  static const String _boxName = "envGroupDb";

  static Future<void> openBox() async {
    await Hive.openBox<EnvGroupEntity>(_boxName);
  }

  static Box<EnvGroupEntity>? _box;

  static _initBox() {
    _box ??= Hive.box<EnvGroupEntity>(_boxName);
  }

  static void insertOrUpdate(EnvGroupEntity entity) {
    _initBox();
    int index = _box!.values
        .toList()
        .indexWhere((p) => p.envGroupName == entity.envGroupName);

    if (index != -1) {
      _box!.putAt(index, entity); // 执行更新操作
    } else {
      _box!.add(entity); // 执行插入操作
    }
  }

  static EnvGroupEntity? find(String envGroupName) {
    _initBox();
    int index =
        _box!.values.toList().indexWhere((p) => p.envGroupName == envGroupName);
    if (index != -1) {
      return _box!.values.toList()[index];
    } else {
      return null;
    }
  }

  /// 列举
  static List<EnvGroupEntity> list() {
    _initBox();
    return _box!.values.toList();
  }

  static void clear() {
    _initBox();
    _box!.clear();
  }
}
