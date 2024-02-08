// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_record_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectRecordEntityAdapter extends TypeAdapter<ProjectRecordEntity> {
  @override
  final int typeId = 73;

  @override
  ProjectRecordEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectRecordEntity(
      fields[1] as String,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectRecordEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.gitUrl)
      ..writeByte(2)
      ..write(obj.branch);
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
