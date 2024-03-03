// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env_check_result_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnvCheckResultEntityAdapter extends TypeAdapter<EnvCheckResultEntity> {
  @override
  final int typeId = 4;

  @override
  EnvCheckResultEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnvCheckResultEntity(
      envPath: fields[2] as String,
      envName: fields[1] as String,
    )..envCheckResult = fields[3] as String?;
  }

  @override
  void write(BinaryWriter writer, EnvCheckResultEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.envName)
      ..writeByte(2)
      ..write(obj.envPath)
      ..writeByte(3)
      ..write(obj.envCheckResult);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvCheckResultEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
