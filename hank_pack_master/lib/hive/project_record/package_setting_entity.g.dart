// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_setting_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PackageSettingAdapter extends TypeAdapter<PackageSetting> {
  @override
  final int typeId = 5;

  @override
  PackageSetting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PackageSetting(
      appUpdateLog: fields[1] as String?,
      apkLocation: fields[2] as String?,
      selectedOrder: fields[3] as String?,
      selectedUploadPlatform: fields[4] as UploadPlatform?,
      jdk: fields[6] as EnvCheckResultEntity?,
      mergeBranchList: (fields[5] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PackageSetting obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.appUpdateLog)
      ..writeByte(2)
      ..write(obj.apkLocation)
      ..writeByte(3)
      ..write(obj.selectedOrder)
      ..writeByte(4)
      ..write(obj.selectedUploadPlatform)
      ..writeByte(5)
      ..write(obj.mergeBranchList)
      ..writeByte(6)
      ..write(obj.jdk);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PackageSettingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
