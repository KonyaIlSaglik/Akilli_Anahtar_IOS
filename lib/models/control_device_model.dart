// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/entities/device_type.dart';

class ControlDeviceModel {
  int id;
  String name;
  int deviceTypeId;
  String topicStat;
  String topicRec;
  String topicRes;
  String description;
  int boxId;
  String pin;
  int active;
  Box? box;
  DeviceType? deviceType;
  ControlDeviceModel({
    this.id = 0,
    this.name = "",
    this.deviceTypeId = 0,
    this.topicStat = "",
    this.topicRec = "",
    this.topicRes = "",
    this.description = "",
    this.boxId = 0,
    this.pin = "",
    this.active = 1,
    this.box,
    this.deviceType,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'device_type_id': deviceTypeId,
      'topic_stat': topicStat,
      'topic_rec': topicRec,
      'topic_res': topicRes,
      'description': description,
      'box_id': boxId,
      'pin': pin,
      'active': active,
      'box': box?.toMap(),
      'deviceType': deviceType?.toMap(),
    };
  }

  factory ControlDeviceModel.fromMap(Map<String, dynamic> map) {
    return ControlDeviceModel(
      id: map['id'] as int,
      name: map['name'] as String,
      deviceTypeId: map['device_type_id'] as int,
      topicStat: map['topicStat'] as String,
      topicRec: map['topicRec'] as String,
      topicRes: map['topicRes'] as String,
      description: map['description'] as String,
      boxId: map['boxId'] as int,
      pin: map['pin'] as String,
      active: map['active'] as int,
      box: map['box'] != null
          ? Box.fromMap(map['box'] as Map<String, dynamic>)
          : null,
      deviceType: map['deviceType'] != null
          ? DeviceType.fromMap(map['deviceType'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ControlDeviceModel.fromJson(String source) =>
      ControlDeviceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
