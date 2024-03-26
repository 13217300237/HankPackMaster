import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/hive/project_record/job_history_entity.dart';
import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';
import 'package:hive/hive.dart';
import 'package:hank_pack_master/comm/text_util.dart';

import 'job_result_entity.dart';

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

  static bool insert(ProjectRecordEntity entity) {
    _initBox();
    int index = _box!.values.toList().indexWhere(
        (p) => p.gitUrl == entity.gitUrl && p.branch == entity.branch);

    if (index > 0) {
      // 正数表示已存在相同git和branch的项，就不允许再次录入了
      return false;
    }
    _box!.add(entity); // 执行插入操作
    return true;
  }

  static bool update(ProjectRecordEntity entity) {
    _initBox();
    int index = _box!.values.toList().indexWhere(
        (p) => p.gitUrl == entity.gitUrl && p.branch == entity.branch);

    if (index < 0) {
      // 负数表示不存在相同git和branch的项，不允许更新
      return false;
    }
    _box!.putAt(index, entity); // 执行更新操作
    return true;
  }

  static void debugShowAll() {
    var findAllResult = findAll();
    debugPrint("============show start");

    for (int i = 0; i < findAllResult.length; i++) {
      var e = findAllResult[i];
      debugPrint(
          ">>>index=$i>>>>>>\n ${e.projectName} - ${e.assembleOrdersStr?.trim()}    \n<<<<<<<<<");
    }

    debugPrint("show end=============\n\n\n");
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

    debugPrint("allProject.length-> ${allProject.length}");

    for (var e in allProject) {
      var temp = e.jobHistoryList;
      debugPrint("for.e.jobHistoryList-> ${e.jobHistoryList}");
      temp?.forEach((j) {
        j.projectName = e.projectName;
        j.gitUrl = e.gitUrl;
        j.branchName = e.branch;
        j.projectDesc = e.projectDesc;
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

  static List<JobHistoryEntity> findALlHis() {
    List<JobHistoryEntity> list = [];

    var allProject = findAll();

    for (var e in allProject) {
      var temp = e.jobHistoryList;
      temp?.forEach((j) {
        j.projectName = e.projectName;
        j.gitUrl = e.gitUrl;
        j.branchName = e.branch;
        j.projectDesc = e.projectDesc;
      });

      if (temp != null) {
        list.addAll(temp);
      }
    }

    return list;
  }

  /// 找出所有未读的作业历史
  static List<JobHistoryEntity> findAllUnreadJobHistoryEntity() {
    var recent = findALlHis();

    recent.removeWhere((e) => e.hasRead == true);

    return recent;
  }

  /// 将指定工程的某一条历史记录设置为已读并入库
  static void setRead({
    required ProjectRecordEntity projectRecordEntity,
    required JobHistoryEntity jobHistoryEntity,
  }) {
    _initBox();
    jobHistoryEntity.hasRead = true;
    int projectRecordIndex = _box!.values.toList().indexWhere((p) =>
        p.gitUrl == projectRecordEntity.gitUrl &&
        p.branch == projectRecordEntity.branch);

    if (projectRecordIndex == -1) {
      // 没找到该条工程记录，拒绝执行setRead
      return;
    }

    var find = _box!.values.toList()[projectRecordIndex]; // 找到这条工程记录
    if (find.jobHistoryList == null) {
      // 如果这条记录没有历史，那就没办法更新历史记录
      return;
    }

    var hisIndex = find.jobHistoryList!.indexWhere((e) =>
        e.buildTime == jobHistoryEntity.buildTime &&
        e.jobResultEntity == jobHistoryEntity.jobResultEntity); // 尝试找到这一条历史记录

    if (hisIndex == -1) {
      // 没找到
      return;
    }

    var findHis = find.jobHistoryList![hisIndex]; // 再找到这条历史记录
    findHis.hasRead = true;

    debugPrint("setRead $projectRecordIndex");
    _box!.putAt(projectRecordIndex, projectRecordEntity);

    debugShowAll();
  }

  /// 将指定工程的某一条历史记录设置为已读并入库
  static void setReadV2({required JobHistoryEntity jobHistoryEntity}) {
    _initBox();

    if (jobHistoryEntity.hasRead == true) {
      // 已经阅读过的，不再入库
      return;
    }

    jobHistoryEntity.hasRead = true;
    int projectRecordIndex = _box!.values.toList().indexWhere((p) =>
        p.gitUrl == jobHistoryEntity.gitUrl &&
        p.branch == jobHistoryEntity.branchName);

    if (projectRecordIndex == -1) {
      // 没找到该条工程记录，拒绝执行setRead
      return;
    }

    var projectRecordEntity =
        find(jobHistoryEntity.gitUrl!, jobHistoryEntity.branchName!);

    var findRes = _box!.values.toList()[projectRecordIndex]; // 找到这条工程记录
    if (findRes.jobHistoryList == null) {
      // 如果这条记录没有历史，那就没办法更新历史记录
      return;
    }

    var hisIndex = findRes.jobHistoryList!.indexWhere((e) =>
        e.buildTime == jobHistoryEntity.buildTime &&
        e.jobResultEntity == jobHistoryEntity.jobResultEntity); // 尝试找到这一条历史记录

    if (hisIndex == -1) {
      // 没找到
      return;
    }

    var findHis = findRes.jobHistoryList![hisIndex]; // 再找到这条历史记录
    findHis.hasRead = true;

    debugPrint("setRead $projectRecordIndex");
    _box!.putAt(projectRecordIndex, projectRecordEntity!);

    debugShowAll();
  }

  /// 找出所有需要快速上传的失败历史
  static List<JobHistoryEntity> findFastUploadTaskList() {
    List<JobHistoryEntity> list = findALlHis().reversed.toList();
    list.removeWhere((e) => e.success == true); // 先删除所有成功的
    // 再找出所有支持快速上传的 历史记录
    list.removeWhere((e) => !needFastUpload(e)); // 再把不需要快速上传的失败记录去掉
    // 现在就只剩下了需要快速上传的记录了...
    List<JobHistoryEntity> newList = [];
    for (var e in list) {
      if (!newList.contains(e)) {
        newList.add(e);
      }
    }

    return newList;
  }

  /// 判断是否需要快速上传
  static bool needFastUpload(JobHistoryEntity historyEntity) {
    // 尝试把 错误码
    try {
      JobResultEntity jobResultEntity = historyEntity.jobResultEntity;

      debugPrint('jobResultEntity.apkPath-> ${jobResultEntity.apkPath}');

      if (jobResultEntity.apkPath.empty()) {
        return false;
      }

      var f = File(jobResultEntity.apkPath!);
      if (f.existsSync()) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
