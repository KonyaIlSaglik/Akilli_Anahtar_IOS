// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Device {
  int id;
  String name;
  int typeId;
  String typeName;
  int boxId;
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
  int? normalValueRangeId;
  int? criticalValueRangeId;
  int? unitId;
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
    this.typeName = "",
    this.boxId = 0,
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
    this.active = 0,
    this.rfCodes,
    this.normalValueRangeId,
    this.criticalValueRangeId,
    this.unitId,
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
      typeName: map['typeName'] as String,
      boxId: map['boxId'] as int,
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
      rfCodes: map['rfCodes'] != null
          ? List<String>.from((map['rfCodes'] as List<String>))
          : null,
      normalValueRangeId: map['normalValueRangeId'] != null
          ? map['normalValueRangeId'] as int
          : null,
      criticalValueRangeId: map['criticalValueRangeId'] != null
          ? map['criticalValueRangeId'] as int
          : null,
      unitId: map['unitId'] != null ? map['unitId'] as int : null,
      unit: map['unit'] != null ? map['unit'] as String : null,
      normalMinValue: map['normalMinValue'] != null
          ? map['normalMinValue'] as double
          : null,
      normalMaxValue: map['normalMaxValue'] != null
          ? map['normalMaxValue'] as double
          : null,
      criticalMinValue: map['criticalMinValue'] != null
          ? map['criticalMinValue'] as double
          : null,
      criticalMaxValue: map['criticalMaxValue'] != null
          ? map['criticalMaxValue'] as double
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
