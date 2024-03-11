// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_platforms.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UploadPlatformAdapter extends TypeAdapter<UploadPlatform> {
  @override
  final int typeId = 6;

  @override
  UploadPlatform read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UploadPlatform(
      name: fields[1] as String?,
      index: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UploadPlatform obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadPlatformAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
