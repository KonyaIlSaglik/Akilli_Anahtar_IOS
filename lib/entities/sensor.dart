// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Sensor {
  int id;
  String name;
  int deviceTypeId;
  int? mainSensorId;
  String topicStat;
  String? description;
  int boxId;
  String pin;
  int active;
  String unit;
  String? topicMessage;

  Sensor({
    required this.id,
    required this.name,
    required this.deviceTypeId,
    this.mainSensorId,
    required this.topicStat,
    this.description,
    required this.boxId,
    required this.pin,
    required this.active,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'deviceTypeId': deviceTypeId,
      'mainSensorId': mainSensorId,
      'topicStat': topicStat,
      'description': description,
      'boxId': boxId,
      'pin': pin,
      'active': active,
      'unit': unit,
    };
  }

  factory Sensor.fromMap(Map<String, dynamic> map) {
    return Sensor(
      id: map['id'] as int,
      name: map['name'] as String,
      deviceTypeId: map['deviceTypeId'] as int,
      mainSensorId:
          map['mainSensorId'] != null ? map['mainSensorId'] as int : null,
      topicStat: map['topicStat'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      boxId: map['boxId'] as int,
      pin: map['pin'] as String,
      active: map['active'] as int,
      unit: map['unit'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Sensor.fromJson(String source) =>
      Sensor.fromMap(json.decode(source) as Map<String, dynamic>);
}
