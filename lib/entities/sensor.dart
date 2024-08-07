import 'dart:convert';

class Sensors {
  int id;
  String name;
  int deviceTypeId;
  int mainSensorId;
  String topicStat;
  String description;
  int boxId;
  String pin;
  int active;
  String unit;

  Sensors({
    required this.id,
    required this.name,
    required this.deviceTypeId,
    required this.mainSensorId,
    required this.topicStat,
    required this.description,
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

  factory Sensors.fromMap(Map<String, dynamic> map) {
    return Sensors(
      id: map['id'] as int,
      name: map['name'] as String,
      deviceTypeId: map['deviceTypeId'] as int,
      mainSensorId: map['mainSensorId'] as int,
      topicStat: map['topicStat'] as String,
      description: map['description'] as String,
      boxId: map['boxId'] as int,
      pin: map['pin'] as String,
      active: map['active'] as int,
      unit: map['unit'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Sensors.fromJson(String source) =>
      Sensors.fromMap(json.decode(source) as Map<String, dynamic>);
}
