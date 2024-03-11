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
      fields[1] as String,
      fields[2] as String,
      fields[4] as String,
      fields[8] as String?,
      preCheckOk: fields[3] as bool,
      jobRunning: fields[7] as bool?,
      assembleOrders: (fields[5] as List?)?.cast<String>(),
      jobHistory: (fields[6] as List?)?.cast<String>(),
    )
      ..activeSetting = fields[9] as PackageSetting?
      ..packageSetting = fields[16] as PackageSetting?
      ..fastUploadSetting = fields[17] as PackageSetting?;
  }

  @override
  void write(BinaryWriter writer, ProjectRecordEntity obj) {
    writer
      ..writeByte(11)
      ..writeByte(4)
      ..write(obj.projectName)
      ..writeByte(1)
      ..write(obj.gitUrl)
      ..writeByte(2)
      ..write(obj.branch)
      ..writeByte(3)
      ..write(obj.preCheckOk)
      ..writeByte(5)
      ..write(obj.assembleOrders)
      ..writeByte(6)
      ..write(obj.jobHistory)
      ..writeByte(7)
      ..write(obj.jobRunning)
      ..writeByte(8)
      ..write(obj.projectDesc)
      ..writeByte(9)
      ..write(obj.activeSetting)
      ..writeByte(16)
      ..write(obj.packageSetting)
      ..writeByte(17)
      ..write(obj.fastUploadSetting);
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
