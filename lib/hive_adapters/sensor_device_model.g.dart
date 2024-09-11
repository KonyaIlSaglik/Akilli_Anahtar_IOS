// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../models/sensor_device_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SensorDeviceModelAdapter extends TypeAdapter<SensorDeviceModel> {
  @override
  final int typeId = 7;

  @override
  SensorDeviceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SensorDeviceModel(
      id: fields[0] as int?,
      name: fields[1] as String?,
      deviceTypeId: fields[2] as int?,
      topicStat: fields[3] as String?,
      description: fields[4] as String?,
      boxId: fields[5] as int?,
      pin: fields[6] as String?,
      active: fields[7] as int?,
      unit: fields[8] as String?,
      valueRangeId: fields[9] as int?,
      valueRangeMin: fields[10] as double?,
      valueRangeMax: fields[11] as double?,
      deviceTypeName: fields[12] as String?,
      deviceTypeMenuId: fields[13] as int?,
      boxName: fields[14] as String?,
      boxOrganisationId: fields[15] as int?,
      boxOrganisationName: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SensorDeviceModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.deviceTypeId)
      ..writeByte(3)
      ..write(obj.topicStat)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.boxId)
      ..writeByte(6)
      ..write(obj.pin)
      ..writeByte(7)
      ..write(obj.active)
      ..writeByte(8)
      ..write(obj.unit)
      ..writeByte(9)
      ..write(obj.valueRangeId)
      ..writeByte(10)
      ..write(obj.valueRangeMin)
      ..writeByte(11)
      ..write(obj.valueRangeMax)
      ..writeByte(12)
      ..write(obj.deviceTypeName)
      ..writeByte(13)
      ..write(obj.deviceTypeMenuId)
      ..writeByte(14)
      ..write(obj.boxName)
      ..writeByte(15)
      ..write(obj.boxOrganisationId)
      ..writeByte(16)
      ..write(obj.boxOrganisationName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SensorDeviceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
