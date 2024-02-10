import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';
import 'package:hank_pack_master/hive/project_record/project_record_type_set.dart';
import 'package:hive/hive.dart';

class ProjectRecordOperator {
  static Future<void> openBox() async {
    Hive.registerAdapter(ProjectRecordEntityAdapter(), override: true);
    await Hive.openBox(projectRecordBoxName);
  }

  static Box<ProjectRecordEntity>? _box;

  static _initBox() {
    _box ??= Hive.box(projectRecordBoxName);
  }

  static void insertOrUpdate(ProjectRecordEntity entity) {
    _initBox();
    int index = _box!.values.toList().indexWhere(
        (p) => p.gitUrl == entity.gitUrl && p.branch == entity.branch);

    if (index != -1) {
      _box!.putAt(index, entity); // 执行更新操作
    } else {
      _box!.add(entity); // 执行插入操作
    }
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


}
