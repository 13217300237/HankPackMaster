// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_result_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobResultEntityAdapter extends TypeAdapter<JobResultEntity> {
  @override
  final int typeId = 9;

  @override
  JobResultEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobResultEntity(
      buildKey: fields[2] as String?,
      buildType: fields[3] as String?,
      buildIsFirst: fields[4] as String?,
      buildIsLastest: fields[5] as String?,
      buildFileKey: fields[6] as String?,
      buildFileName: fields[7] as String?,
      buildFileSize: fields[8] as String?,
      buildName: fields[9] as String?,
      buildVersion: fields[10] as String?,
      buildVersionNo: fields[11] as String?,
      buildBuildVersion: fields[12] as String?,
      buildIdentifier: fields[13] as String?,
      buildIcon: fields[14] as String?,
      buildDescription: fields[15] as String?,
      buildUpdateDescription: fields[16] as String?,
      buildScreenshots: fields[17] as String?,
      buildShortcutUrl: fields[18] as String?,
      buildCreated: fields[19] as String?,
      buildUpdated: fields[20] as String?,
      buildQRCodeURL: fields[21] as String?,
      uploadPlatform: fields[1] as String?,
      errCode: fields[23] as String?,
      errMessage: fields[22] as String?,
      assembleOrders: (fields[24] as List?)?.cast<String>(),
      apkPath: fields[25] as String?,
    )..expiredTime = fields[26] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, JobResultEntity obj) {
    writer
      ..writeByte(26)
      ..writeByte(1)
      ..write(obj.uploadPlatform)
      ..writeByte(2)
      ..write(obj.buildKey)
      ..writeByte(3)
      ..write(obj.buildType)
      ..writeByte(4)
      ..write(obj.buildIsFirst)
      ..writeByte(5)
      ..write(obj.buildIsLastest)
      ..writeByte(6)
      ..write(obj.buildFileKey)
      ..writeByte(7)
      ..write(obj.buildFileName)
      ..writeByte(8)
      ..write(obj.buildFileSize)
      ..writeByte(9)
      ..write(obj.buildName)
      ..writeByte(10)
      ..write(obj.buildVersion)
      ..writeByte(11)
      ..write(obj.buildVersionNo)
      ..writeByte(12)
      ..write(obj.buildBuildVersion)
      ..writeByte(13)
      ..write(obj.buildIdentifier)
      ..writeByte(14)
      ..write(obj.buildIcon)
      ..writeByte(15)
      ..write(obj.buildDescription)
      ..writeByte(16)
      ..write(obj.buildUpdateDescription)
      ..writeByte(17)
      ..write(obj.buildScreenshots)
      ..writeByte(18)
      ..write(obj.buildShortcutUrl)
      ..writeByte(19)
      ..write(obj.buildCreated)
      ..writeByte(20)
      ..write(obj.buildUpdated)
      ..writeByte(21)
      ..write(obj.buildQRCodeURL)
      ..writeByte(22)
      ..write(obj.errMessage)
      ..writeByte(23)
      ..write(obj.errCode)
      ..writeByte(24)
      ..write(obj.assembleOrders)
      ..writeByte(25)
      ..write(obj.apkPath)
      ..writeByte(26)
      ..write(obj.expiredTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobResultEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
