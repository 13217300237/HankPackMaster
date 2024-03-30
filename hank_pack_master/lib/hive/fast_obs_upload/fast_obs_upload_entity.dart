import 'package:hive/hive.dart';

part 'fast_obs_upload_entity.g.dart';

/// OBS快速上传配置
@HiveType(typeId: 10)
class FastObsUploadEntity {
  /// 本地文件路径
  @HiveField(1)
  String filePath; //

  @HiveField(2)
  String fileName;

  @HiveField(3)
  int fileSize;

  @HiveField(4)
  DateTime fileLastModify;

  @HiveField(5)
  DateTime uploadTime;

  @HiveField(6)
  int expiredDays;

  @HiveField(7)
  String downloadUrl;

  @HiveField(8)
  DateTime expiredTime;

  FastObsUploadEntity(
    this.filePath,
    this.fileName,
    this.fileSize,
    this.fileLastModify,
    this.uploadTime,
    this.expiredDays,
    this.downloadUrl,
    this.expiredTime,
  );
}
