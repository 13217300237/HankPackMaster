import 'package:hank_pack_master/hive/project_record/package_setting_entity.dart';
import 'package:hive/hive.dart';

import 'job_history_entity.dart';

part 'project_record_entity.g.dart';

/// 打包任务实体类
/// 概念：当设定一个 gitUrl 和 branch 时，一个 projectRecord就已经确定，后续它的打包结果，都会依附于此projectRecord
@HiveType(typeId: 2)
class ProjectRecordEntity {
  @HiveField(1)
  late String projectName;

  @HiveField(2)
  late String gitUrl;

  @HiveField(3)
  late String branch;

  @HiveField(4)
  late bool preCheckOk; // 是否已预检成功

  @HiveField(5)
  bool? jobRunning;

  @HiveField(6)
  String? projectDesc;

  @HiveField(7)
  PackageSetting? activeSetting; // 激活阶段的配置

  @HiveField(8)
  PackageSetting? packageSetting; // 打包阶段的配置

  @HiveField(9)
  PackageSetting? fastUploadSetting; // 快速上传阶段的配置

  @HiveField(10)
  String? assembleOrdersStr; // 换个方式存储可用变体 原来用listString会出现问题

  @HiveField(11)
  List<JobHistoryEntity>? jobHistoryList; // 换个方式存储作业历史

  List<String> strArrToList() {
    List<String> list = [];
    var split = assembleOrdersStr!.split("\n");
    for (var e in split) {
      if (e.isNotEmpty) {
        list.add(e.trim());
      }
    }
    return list;
  }

  List<String> get assembleOrderList {
    if (assembleOrdersStr == null) return [];
    var list = strArrToList();
    int oriLength = list.length;

    // 这里先判断命令的节数，找出最大节数值
    // 然后遍历所有的命令，仅保留节数值符合最大节数值的命令
    int maxWords = findMaxWords(list);
    list.removeWhere((element) => countUppercaseLetters(element) != maxWords);
    int afterFilterLength = list.length;

    // 检查最后剩余的命令数量，和之前数量之差,如果减少过半，那就显示原所有命令
    if (afterFilterLength < oriLength / 2) {
      return strArrToList();
    } else {
      return list;
    }
  }

  /// 找出一个字符串数组中，每个单词的大写字母数量的最大值
  int findMaxWords(List<String> tasks) {
    int maxWords = 0;

    for (String task in tasks) {
      int wordCount = countUppercaseLetters(task);
      if (wordCount > maxWords) {
        maxWords = wordCount;
      }
    }

    return maxWords;
  }

  /// 计算字符串中大写字母的数量
  int countUppercaseLetters(String str) {
    int count = 0;

    for (int i = 0; i < str.length; i++) {
      if (str.codeUnitAt(i) >= 65 && str.codeUnitAt(i) <= 90) {
        // 65到90，对应 A到Z
        count++;
      }
    }

    return count;
  }

  /// 临时字段，不用存数据库
  /// 传递给工坊的对象，包含了打包所需的所有参数
  PackageSetting? settingToWorkshop;

  double processValue = 0;

  // 用一个字段保存apk路径(只有上传失败的任务才会短暂保存这个值)
  String? apkPath;

  ProjectRecordEntity(
    this.gitUrl,
    this.branch,
    this.projectName,
    this.projectDesc, {
    this.preCheckOk = false,
    this.jobRunning = false,
  });

  ProjectRecordEntity clone() {
    var cloneOne =
        ProjectRecordEntity(gitUrl, branch, projectName, projectDesc);
    cloneOne.preCheckOk = preCheckOk;
    cloneOne.jobRunning = jobRunning;
    cloneOne.assembleOrdersStr = assembleOrdersStr;
    return cloneOne;
  }

  @override
  String toString() {
    return "$projectName \n $gitUrl \n  $branch";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectRecordEntity &&
        other.gitUrl == gitUrl &&
        other.branch == branch;
  }

  /// 获得所有未读历史的数量
  int get getUnReadHisCount =>
      jobHistoryList?.where((element) => element.hasRead != true).length ?? 0;

  @override
  int get hashCode => branch.hashCode ^ gitUrl.hashCode;
}
