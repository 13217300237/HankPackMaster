import 'package:hank_pack_master/hive/fast_obs_upload/fast_obs_upload_entity.dart';
import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';
import 'package:hive/hive.dart';


class FastObsUploadOperator {
  /// 盒子名称
  static const String _boxName = "fastObsUploadDb"; // 每一次更新

  static Future<void> openBox() async {
    await Hive.openBox<ProjectRecordEntity>(_boxName);
  }

  static Box<FastObsUploadEntity>? _box;

  static _initBox() {
    _box ??= Hive.box<FastObsUploadEntity>(_boxName);
  }

  static bool insert(FastObsUploadEntity entity) {
    _initBox();
    _box!.add(entity); // 执行插入操作
    return true;
  }


  static List<FastObsUploadEntity> findAll() {
    _initBox();
    return _box!.values.toList();
  }

}
