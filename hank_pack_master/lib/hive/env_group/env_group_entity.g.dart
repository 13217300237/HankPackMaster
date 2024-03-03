// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env_group_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnvGroupEntityAdapter extends TypeAdapter<EnvGroupEntity> {
  @override
  final int typeId = 3;

  @override
  EnvGroupEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnvGroupEntity(
      envGroupName: fields[1] as String,
    )..envValue = (fields[2] as List?)?.cast<EnvCheckResultEntity>();
  }

  @override
  void write(BinaryWriter writer, EnvGroupEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.envGroupName)
      ..writeByte(2)
      ..write(obj.envValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvGroupEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
