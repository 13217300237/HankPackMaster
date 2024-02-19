import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';
import 'package:hive/hive.dart';

class ProjectRecordOperator {
  /// 盒子名称
  static const String _boxName = "projectRecordDbV2"; // 每一次更新

  static Future<void> openBox() async {
    Hive.registerAdapter(ProjectRecordEntityAdapter(), override: true);
    await Hive.openBox<ProjectRecordEntity>(_boxName);
  }

  static Box<ProjectRecordEntity>? _box;

  static _initBox() {
    _box ??= Hive.box<ProjectRecordEntity>(_boxName);
  }

  static void insertOrUpdate(ProjectRecordEntity entity) {
    _initBox();
    int index = _box!.values.toList().indexWhere(
        (p) => p.gitUrl == entity.gitUrl && p.branch == entity.branch);

    if (index != -1) {
      debugPrint(
          "执行更新 ${entity.gitUrl}  ${entity.branch} ${entity.preCheckOk}");
      _box!.putAt(index, entity); // 执行更新操作
    } else {
      debugPrint("执行插入");
      _box!.add(entity); // 执行插入操作
    }
  }

  static List<ProjectRecordEntity> findAll() {
    _initBox();
    return _box!.values.toList();
  }

  static void delete(ProjectRecordEntity entity) {
    _initBox();
    int index = _box!.values.toList().indexWhere(
        (p) => p.gitUrl == entity.gitUrl && p.branch == entity.branch);

    if (index != -1) {
      _box!.deleteAt(index); // 执行删除操作
    } else {
      throw Exception("找不到该条记录，无法删除");
    }
  }

  static ProjectRecordEntity? find(String gitUrl, String branch) {
    _initBox();
    try {
      return _box!.values
          .firstWhere((p) => p.gitUrl == gitUrl && p.branch == branch);
    } catch (e) {
      return null;
    }
  }

  static Future<int>? clear() {
    _initBox();
    try {
      return _box!.clear();
    } catch (e) {
      debugPrint('删除全部时出现问题:$e');
      return null;
    }
  }
}
