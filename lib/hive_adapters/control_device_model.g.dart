// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../models/control_device_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ControlDeviceModelAdapter extends TypeAdapter<ControlDeviceModel> {
  @override
  final int typeId = 6;

  @override
  ControlDeviceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ControlDeviceModel(
      id: fields[0] as int?,
      name: fields[1] as String?,
      deviceTypeId: fields[2] as int?,
      topicStat: fields[3] as String?,
      topicRec: fields[4] as String?,
      topicRes: fields[5] as String?,
      description: fields[6] as String?,
      boxId: fields[7] as int?,
      pin: fields[8] as String?,
      active: fields[9] as int?,
      deviceTypeName: fields[10] as String?,
      deviceTypeMenuId: fields[11] as int?,
      boxName: fields[12] as String?,
      boxOrganisationId: fields[13] as int?,
      boxOrganisationName: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ControlDeviceModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.deviceTypeId)
      ..writeByte(3)
      ..write(obj.topicStat)
      ..writeByte(4)
      ..write(obj.topicRec)
      ..writeByte(5)
      ..write(obj.topicRes)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.boxId)
      ..writeByte(8)
      ..write(obj.pin)
      ..writeByte(9)
      ..write(obj.active)
      ..writeByte(10)
      ..write(obj.deviceTypeName)
      ..writeByte(11)
      ..write(obj.deviceTypeMenuId)
      ..writeByte(12)
      ..write(obj.boxName)
      ..writeByte(13)
      ..write(obj.boxOrganisationId)
      ..writeByte(14)
      ..write(obj.boxOrganisationName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ControlDeviceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
