// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:akilli_anahtar/utils/hive_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
    };
  }

  factory ControlDeviceModel.fromMap(Map<String, dynamic> map) {
    return ControlDeviceModel(
      id: map['id'] as int?,
      name: map['name'] as String?,
      deviceTypeId: map['deviceTypeId'] as int?,
      topicStat: map['topicStat'] as String?,
      topicRec: map['topicRec'] as String?,
      topicRes: map['topicRes'] as String?,
      description: map['description'] as String?,
      boxId: map['boxId'] as int?,
      pin: map['pin'] as String?,
      active: map['active'] as int?,
      deviceTypeName: map['deviceTypeName'] as String?,
      deviceTypeMenuId: map['deviceTypeMenuId'] as int?,
      boxName: map['boxName'] as String?,
      boxOrganisationId: map['boxOrganisationId'] as int?,
      boxOrganisationName: map['boxOrganisationName'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ControlDeviceModel.fromJson(String source) =>
      ControlDeviceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
