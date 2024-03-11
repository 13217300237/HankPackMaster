import 'package:hive/hive.dart';

import '../../comm/upload_platforms.dart';

part 'upload_platforms.g.dart';

@HiveType(typeId: 6)
class UploadPlatform {
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final int? index;

  UploadPlatform({this.name, this.index});

  static UploadPlatform pgy = UploadPlatform(name: '蒲公英平台', index: 0);
  static UploadPlatform hwobs = UploadPlatform(name: '华为obs平台', index: 1);

  static String findNameByIndex(String index) {
    for (var e in uploadPlatforms) {
      if ("${e.index}" == index) {
        return e.name!;
      }
    }

    return "";
  }
}
