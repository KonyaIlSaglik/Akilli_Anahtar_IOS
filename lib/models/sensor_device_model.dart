import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:akilli_anahtar/utils/hive_constants.dart';

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

  @HiveField(17)
  List<String>? rfCodes;

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
    this.rfCodes,
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
      'rfCodes': json.encode(rfCodes),
    };
  }

  factory SensorDeviceModel.fromMap(Map<String, dynamic> map) {
    return SensorDeviceModel(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] != null ? map['name'] as String : null,
      deviceTypeId:
          map['deviceTypeId'] != null ? map['deviceTypeId'] as int : null,
      topicStat: map['topicStat'] != null ? map['topicStat'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      boxId: map['boxId'] != null ? map['boxId'] as int : null,
      pin: map['pin'] != null ? map['pin'] as String : null,
      active: map['active'] != null ? map['active'] as int : null,
      unit: map['unit'] != null ? map['unit'] as String : null,
      valueRangeId:
          map['valueRangeId'] != null ? map['valueRangeId'] as int : null,
      valueRangeMin:
          map['valueRangeMin'] != null ? map['valueRangeMin'] as double : null,
      valueRangeMax:
          map['valueRangeMax'] != null ? map['valueRangeMax'] as double : null,
      deviceTypeName: map['deviceTypeName'] != null
          ? map['deviceTypeName'] as String
          : null,
      deviceTypeMenuId: map['deviceTypeMenuId'] != null
          ? map['deviceTypeMenuId'] as int
          : null,
      boxName: map['boxName'] != null ? map['boxName'] as String : null,
      boxOrganisationId: map['boxOrganisationId'] != null
          ? map['boxOrganisationId'] as int
          : null,
      boxOrganisationName: map['boxOrganisationName'] != null
          ? map['boxOrganisationName'] as String
          : null,
      rfCodes: map['rfCodes'] != null
          ? List<String>.from(
              (map['rfCodes'] as List<dynamic>).map((item) => item.toString()))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SensorDeviceModel.fromJson(String source) =>
      SensorDeviceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
