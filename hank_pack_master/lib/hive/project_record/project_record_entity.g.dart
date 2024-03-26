// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_record_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectRecordEntityAdapter extends TypeAdapter<ProjectRecordEntity> {
  @override
  final int typeId = 2;

  @override
  ProjectRecordEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectRecordEntity(
      fields[2] as String,
      fields[3] as String,
      fields[1] as String,
      fields[6] as String?,
      preCheckOk: fields[4] as bool,
      jobRunning: fields[5] as bool?,
    )
      ..activeSetting = fields[7] as PackageSetting?
      ..packageSetting = fields[8] as PackageSetting?
      ..fastUploadSetting = fields[9] as PackageSetting?
      ..assembleOrdersStr = fields[10] as String?
      ..jobHistoryList = (fields[11] as List?)?.cast<JobHistoryEntity>();
  }

  @override
  void write(BinaryWriter writer, ProjectRecordEntity obj) {
    writer
      ..writeByte(11)
      ..writeByte(1)
      ..write(obj.projectName)
      ..writeByte(2)
      ..write(obj.gitUrl)
      ..writeByte(3)
      ..write(obj.branch)
      ..writeByte(4)
      ..write(obj.preCheckOk)
      ..writeByte(5)
      ..write(obj.jobRunning)
      ..writeByte(6)
      ..write(obj.projectDesc)
      ..writeByte(7)
      ..write(obj.activeSetting)
      ..writeByte(8)
      ..write(obj.packageSetting)
      ..writeByte(9)
      ..write(obj.fastUploadSetting)
      ..writeByte(10)
      ..write(obj.assembleOrdersStr)
      ..writeByte(11)
      ..write(obj.jobHistoryList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectRecordEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
