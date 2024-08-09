// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:akilli_anahtar/entities/sensor_value_range.dart';

class SensorDeviceModel {
  int id;
  String name;
  int deviceTypeId;
  String topicStat;
  String description;
  int boxId;
  String pin;
  int active;
  String unit;
  Box? box;
  DeviceType? deviceType;
  SensorValueRange? sensorValueRange;
  SensorDeviceModel({
    this.id = 0,
    this.name = "",
    this.deviceTypeId = 0,
    this.topicStat = "",
    this.description = "",
    this.boxId = 0,
    this.pin = "",
    this.active = 1,
    this.unit = "",
    this.box,
    this.deviceType,
    this.sensorValueRange,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'deviceTypeId': deviceTypeId,
      'topicStat': topicStat,
      'description': description,
      'boxId': boxId,
      'pin': pin,
      'active': active,
      'unit': unit,
      'box': box?.toMap(),
      'deviceType': deviceType?.toMap(),
      'sensorVelueRange': sensorValueRange?.toMap(),
    };
  }

  factory SensorDeviceModel.fromMap(Map<String, dynamic> map) {
    return SensorDeviceModel(
      id: map['id'] as int,
      name: map['name'] as String,
      deviceTypeId: map['deviceTypeId'] as int,
      topicStat: map['topicStat'] as String,
      description: map['description'] as String,
      boxId: map['boxId'] as int,
      pin: map['pin'] as String,
      active: map['active'] as int,
      unit: map['unit'] as String,
      box: map['box'] != null
          ? Box.fromMap(map['box'] as Map<String, dynamic>)
          : null,
      deviceType: map['deviceType'] != null
          ? DeviceType.fromMap(map['deviceType'] as Map<String, dynamic>)
          : null,
      sensorValueRange: map['sensorValueRange'] != null
          ? SensorValueRange.fromMap(
              map['sensorValueRange'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SensorDeviceModel.fromJson(String source) =>
      SensorDeviceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
