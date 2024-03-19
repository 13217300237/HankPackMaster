// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_record_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StageRecordEntityAdapter extends TypeAdapter<StageRecordEntity> {
  @override
  final int typeId = 8;

  @override
  StageRecordEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StageRecordEntity(
      name: fields[1] as String?,
      costTime: fields[2] as int?,
      resultStr: fields[3] as String?,
      fullLog: fields[4] as String?,
    )..success = fields[5] as bool?;
  }

  @override
  void write(BinaryWriter writer, StageRecordEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.costTime)
      ..writeByte(3)
      ..write(obj.resultStr)
      ..writeByte(4)
      ..write(obj.fullLog)
      ..writeByte(5)
      ..write(obj.success);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StageRecordEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
