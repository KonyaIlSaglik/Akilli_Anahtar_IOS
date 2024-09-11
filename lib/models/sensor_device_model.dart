import 'dart:convert';

import 'package:akilli_anahtar/utils/hive_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part '../hive_adapters/sensor_device_model.g.dart';

@HiveType(typeId: HiveConstants.sensorDevicesTypeId)
class SensorDeviceModel {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  int? deviceTypeId;

  @HiveField(3)
  String? topicStat;

  @HiveField(4)
  String? description;

  @HiveField(5)
  int? boxId;

  @HiveField(6)
  String? pin;

  @HiveField(7)
  int? active;

  @HiveField(8)
  String? unit;

  @HiveField(9)
  int? valueRangeId;

  @HiveField(10)
  double? valueRangeMin;

  @HiveField(11)
  double? valueRangeMax;

  @HiveField(12)
  String? deviceTypeName;

  @HiveField(13)
  int? deviceTypeMenuId;

  @HiveField(14)
  String? boxName;

  @HiveField(15)
  int? boxOrganisationId;

  @HiveField(16)
  String? boxOrganisationName;

  bool isSub;

  SensorDeviceModel({
    this.id,
    this.name,
    this.deviceTypeId,
    this.topicStat,
    this.description,
    this.boxId,
    this.pin,
    this.active,
    this.unit,
    this.valueRangeId,
    this.valueRangeMin,
    this.valueRangeMax,
    this.deviceTypeName,
    this.deviceTypeMenuId,
    this.boxName,
    this.boxOrganisationId,
    this.boxOrganisationName,
    this.isSub = false,
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
      'valueRangeId': valueRangeId,
      'valueRangeMin': valueRangeMin,
      'valueRangeMax': valueRangeMax,
      'deviceTypeName': deviceTypeName,
      'deviceTypeMenuId': deviceTypeMenuId,
      'boxName': boxName,
      'boxOrganisationId': boxOrganisationId,
      'boxOrganisationName': boxOrganisationName,
    };
  }

  factory SensorDeviceModel.fromMap(Map<String, dynamic> map) {
    return SensorDeviceModel(
      id: map['id'] as int?,
      name: map['name'] as String?,
      deviceTypeId: map['deviceTypeId'] as int?,
      topicStat: map['topicStat'] as String?,
      description: map['description'] as String?,
      boxId: map['boxId'] as int?,
      pin: map['pin'] as String?,
      active: map['active'] as int?,
      unit: map['unit'] as String?,
      valueRangeId: map['valueRangeId'] as int?,
      valueRangeMin: (map['valueRangeMin'] is num)
          ? (map['valueRangeMin'] as num).toDouble()
          : null,
      valueRangeMax: (map['valueRangeMax'] is num)
          ? (map['valueRangeMax'] as num).toDouble()
          : null,
      deviceTypeName: map['deviceTypeName'] as String?,
      deviceTypeMenuId: map['deviceTypeMenuId'] as int?,
      boxName: map['boxName'] as String?,
      boxOrganisationId: map['boxOrganisationId'] as int?,
      boxOrganisationName: map['boxOrganisationName'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory SensorDeviceModel.fromJson(String source) =>
      SensorDeviceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
