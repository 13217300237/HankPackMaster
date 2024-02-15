// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env_config_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnvConfigEntityAdapter extends TypeAdapter<EnvConfigEntity> {
  @override
  final int typeId = 1;

  @override
  EnvConfigEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnvConfigEntity(
      fields[1] as String,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EnvConfigEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.envName)
      ..writeByte(2)
      ..write(obj.envValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvConfigEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
