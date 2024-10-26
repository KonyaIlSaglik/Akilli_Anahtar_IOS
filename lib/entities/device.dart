// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Device {
  int id;
  String name;
  int typeId;
  String? typeName;
  int boxId;
  int organisationId;
  String topicStat;
  String? topicRec;
  String? topicRes;
  String pin;
  String? description;
  int? openingTime;
  int? waitingTime;
  int? closingTime;
  int? pinMode;
  int? pinStart;
  int active;
  List<String>? rfCodes;
  int normalValueRangeId;
  int criticalValueRangeId;
  int unitId;
  String? unit;
  double? normalMinValue;
  double? normalMaxValue;
  double? criticalMinValue;
  double? criticalMaxValue;
  int? repeatTransmit;

  Device({
    this.id = 0,
    this.name = "",
    this.typeId = 0,
    this.typeName,
    this.boxId = 0,
    this.organisationId = 0,
    this.topicStat = "",
    this.topicRec,
    this.topicRes,
    this.pin = "",
    this.description,
    this.openingTime,
    this.waitingTime,
    this.closingTime,
    this.pinMode,
    this.pinStart,
    this.active = 1,
    this.rfCodes,
    this.normalValueRangeId = 0,
    this.criticalValueRangeId = 0,
    this.unitId = 0,
    this.unit,
    this.normalMinValue,
    this.normalMaxValue,
    this.criticalMinValue,
    this.criticalMaxValue,
    this.repeatTransmit,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'typeId': typeId,
      'typeName': typeName,
      'boxId': boxId,
      'organisationId': organisationId,
      'topicStat': topicStat,
      'topicRec': topicRec,
      'topicRes': topicRes,
      'pin': pin,
      'description': description,
      'openingTime': openingTime,
      'waitingTime': waitingTime,
      'closingTime': closingTime,
      'pinMode': pinMode,
      'pinStart': pinStart,
      'active': active,
      'rfCodes': rfCodes,
      'normalValueRangeId': normalValueRangeId,
      'criticalValueRangeId': criticalValueRangeId,
      'unitId': unitId,
      'unit': unit,
      'normalMinValue': normalMinValue,
      'normalMaxValue': normalMaxValue,
      'criticalMinValue': criticalMinValue,
      'criticalMaxValue': criticalMaxValue,
      'repeatTransmit': repeatTransmit,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] as int,
      name: map['name'] as String,
      typeId: map['typeId'] as int,
      typeName: map['typeName'] != null ? map['typeName'] as String : null,
      boxId: map['boxId'] as int,
      organisationId: map['organisationId'] as int,
      topicStat: map['topicStat'] as String,
      topicRec: map['topicRec'] != null ? map['topicRec'] as String : null,
      topicRes: map['topicRes'] != null ? map['topicRes'] as String : null,
      pin: map['pin'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      openingTime:
          map['openingTime'] != null ? map['openingTime'] as int : null,
      waitingTime:
          map['waitingTime'] != null ? map['waitingTime'] as int : null,
      closingTime:
          map['closingTime'] != null ? map['closingTime'] as int : null,
      pinMode: map['pinMode'] != null ? map['pinMode'] as int : null,
      pinStart: map['pinStart'] != null ? map['pinStart'] as int : null,
      active: map['active'] as int,
      rfCodes: (map['rfCodes'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
      normalValueRangeId: map['normalValueRangeId'] != null
          ? map['normalValueRangeId'] as int
          : 0,
      criticalValueRangeId: map['criticalValueRangeId'] != null
          ? map['criticalValueRangeId'] as int
          : 0,
      unitId: map['unitId'] != null ? map['unitId'] as int : 0,
      unit: map['unit'] != null ? map['unit'] as String : null,
      normalMinValue: map['normalMinValue'] != null
          ? double.tryParse(map['normalMinValue'].toString()) ?? 0.0
          : null,
      normalMaxValue: map['normalMaxValue'] != null
          ? double.tryParse(map['normalMaxValue'].toString()) ?? 0.0
          : null,
      criticalMinValue: map['criticalMinValue'] != null
          ? double.tryParse(map['criticalMinValue'].toString()) ?? 0.0
          : null,
      criticalMaxValue: map['criticalMaxValue'] != null
          ? double.tryParse(map['criticalMaxValue'].toString()) ?? 0.0
          : null,
      repeatTransmit:
          map['repeatTransmit'] != null ? map['repeatTransmit'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Device.fromJson(String source) =>
      Device.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<Device> fromJsonList(String source) =>
      List<Device>.from((json.decode(source) as List<dynamic>)
          .map((x) => Device.fromJson(json.encode(x))));
}
