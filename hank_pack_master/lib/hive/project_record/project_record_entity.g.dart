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
      preCheckOk: fields[3] as bool,
      assembleOrders: (fields[5] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProjectRecordEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.gitUrl)
      ..writeByte(2)
      ..write(obj.branch)
      ..writeByte(3)
      ..write(obj.preCheckOk)
      ..writeByte(4)
      ..write(obj.projectName)
      ..writeByte(5)
      ..write(obj.assembleOrders);
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
