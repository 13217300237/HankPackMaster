// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_history_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobHistoryEntityAdapter extends TypeAdapter<JobHistoryEntity> {
  @override
  final int typeId = 7;

  @override
  JobHistoryEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobHistoryEntity(
      buildTime: fields[3] as int?,
      success: fields[1] as bool?,
      historyContent: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, JobHistoryEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.success)
      ..writeByte(3)
      ..write(obj.buildTime)
      ..writeByte(2)
      ..write(obj.historyContent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobHistoryEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
