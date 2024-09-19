import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:akilli_anahtar/utils/hive_constants.dart';

part '../hive_adapters/control_device_model.g.dart';

@HiveType(typeId: HiveConstants.controlDevicesTypeId)
class ControlDeviceModel {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  int? deviceTypeId;

  @HiveField(3)
  String? topicStat;

  @HiveField(4)
  String? topicRec;

  @HiveField(5)
  String? topicRes;

  @HiveField(6)
  String? description;

  @HiveField(7)
  int? boxId;

  @HiveField(8)
  String? pin;

  @HiveField(9)
  int? active;

  @HiveField(10)
  String? deviceTypeName;

  @HiveField(11)
  int? deviceTypeMenuId;

  @HiveField(12)
  String? boxName;

  @HiveField(13)
  int? boxOrganisationId;

  @HiveField(14)
  String? boxOrganisationName;

  @HiveField(15)
  List<String>? rfCodes;

  bool isSub;

  ControlDeviceModel({
    this.id,
    this.name,
    this.deviceTypeId,
    this.topicStat,
    this.topicRec,
    this.topicRes,
    this.description,
    this.boxId,
    this.pin,
    this.active,
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
      'topicRec': topicRec,
      'topicRes': topicRes,
      'description': description,
      'boxId': boxId,
      'pin': pin,
      'active': active,
      'deviceTypeName': deviceTypeName,
      'deviceTypeMenuId': deviceTypeMenuId,
      'boxName': boxName,
      'boxOrganisationId': boxOrganisationId,
      'boxOrganisationName': boxOrganisationName,
      'rfCodes': json.encode(rfCodes),
    };
  }

  factory ControlDeviceModel.fromMap(Map<String, dynamic> map) {
    return ControlDeviceModel(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] != null ? map['name'] as String : null,
      deviceTypeId:
          map['deviceTypeId'] != null ? map['deviceTypeId'] as int : null,
      topicStat: map['topicStat'] != null ? map['topicStat'] as String : null,
      topicRec: map['topicRec'] != null ? map['topicRec'] as String : null,
      topicRes: map['topicRes'] != null ? map['topicRes'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      boxId: map['boxId'] != null ? map['boxId'] as int : null,
      pin: map['pin'] != null ? map['pin'] as String : null,
      active: map['active'] != null ? map['active'] as int : null,
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

  factory ControlDeviceModel.fromJson(String source) =>
      ControlDeviceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
