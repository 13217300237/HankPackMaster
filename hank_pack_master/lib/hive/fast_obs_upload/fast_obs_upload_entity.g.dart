// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fast_obs_upload_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FastObsUploadEntityAdapter extends TypeAdapter<FastObsUploadEntity> {
  @override
  final int typeId = 10;

  @override
  FastObsUploadEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FastObsUploadEntity(
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as DateTime,
      fields[5] as DateTime,
      fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FastObsUploadEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.fileSize)
      ..writeByte(4)
      ..write(obj.fileLastModify)
      ..writeByte(5)
      ..write(obj.uploadTime)
      ..writeByte(6)
      ..write(obj.expiredDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FastObsUploadEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
