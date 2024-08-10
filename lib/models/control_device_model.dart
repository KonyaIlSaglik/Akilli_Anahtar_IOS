// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ControlDeviceModel {
  int? id;
  String? name;
  int? deviceTypeId;
  String? topicStat;
  String? topicRec;
  String? topicRes;
  String? description;
  int? boxId;
  String? pin;
  int? active;
  String? deviceTypeName;
  int? deviceTypeMenuId;
  String? boxName;
  int? boxOrganisationId;
  String? boxOrganisationName;
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
