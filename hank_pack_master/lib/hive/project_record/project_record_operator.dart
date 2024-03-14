import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/hive/project_record/job_history_entity.dart';
import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';
import 'package:hive/hive.dart';

class ProjectRecordOperator {
  /// 盒子名称
  static const String _boxName = "projectRecordDbV2"; // 每一次更新

  static Future<void> openBox() async {
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
      debugPrint('''
      执行更新 
      index=$index 
      gitUrl=${entity.gitUrl}
      branch=${entity.branch}
      preCheckOk=${entity.preCheckOk}
      assembleOrders=${entity.assembleOrders}
      assembleOrdersStr=${entity.assembleOrdersStr}
      ====================
      ''');
      _box!.putAt(index, entity); // 执行更新操作

      var findAllResult = findAll();
      for (var e in findAllResult) {
        debugPrint(
            "=find== ${e.projectName} - ${e.assembleOrders}   - ${e.assembleOrdersStr} ===");
      }
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

  /// 获取最近10条打包记录
  /// [recentCount] 正数，表示取最大多少条, 为-1时，将会返回所有的打包记录
  static List<JobHistoryEntity> getRecentJobHistoryList(
      {int recentCount = 10}) {
    List<JobHistoryEntity> recent = [];

    var allProject = findAll();

    for (var e in allProject) {
      var temp = e.jobHistoryList;
      temp?.forEach((j) {
        j.projectName = e.projectName;
        j.gitUrl = e.gitUrl;
        j.branchName = e.branch;
      });

      if (temp != null) {
        recent.addAll(temp);
      }
    }

    debugPrint("recent.length-> ${recent.length}");

    recent.sort((c1, c2) {
      return (c2.buildTime ?? 0) - (c1.buildTime ?? 0);
    });

    if (recentCount == -1) {
      return recent;
    }

    if (recent.length > recentCount) {
      return recent.sublist(0, recentCount);
    } else {
      return recent;
    }
  }

  /// 找出所有未读的作业历史
  /// 获取最近10条打包记录
  /// [recentCount] 正数，表示取最大多少条, 为-1时，将会返回所有的打包记录
  static List<JobHistoryEntity> findAllUnreadJobHistoryEntity() {
    List<JobHistoryEntity> recent = [];

    var allProject = findAll();

    for (var e in allProject) {
      var temp = e.jobHistoryList;
      temp?.forEach((j) {
        j.projectName = e.projectName;
        j.gitUrl = e.gitUrl;
        j.branchName = e.branch;
      });

      if (temp != null) {
        recent.addAll(temp);
      }
    }

    recent.removeWhere((e) => e.hasRead == true);

    return recent;
  }

  /// 还缺少setRead方法和 setAllRead方法
}
