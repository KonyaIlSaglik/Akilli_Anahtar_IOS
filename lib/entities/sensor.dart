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
      'device_type_id': deviceTypeId,
      'main_sensor_id': mainSensorId,
      'topic_stat': topicStat,
      'description': description,
      'box_id': boxId,
      'pin': pin,
      'active': active,
      'unit': unit,
    };
  }

  factory Sensor.fromMap(Map<String, dynamic> map) {
    return Sensor(
      id: map['id'] as int,
      name: map['name'] as String,
      deviceTypeId: map['device_type_id'] as int,
      mainSensorId: map['main_sensor_id'] ?? 0,
      topicStat: map['topic_stat'] as String,
      description: map['description'] ?? "",
      boxId: map['box_id'] as int,
      pin: map['pin'] as String,
      active: map['active'] as int,
      unit: map['unit'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Sensor.fromJson(String source) =>
      Sensor.fromMap(json.decode(source) as Map<String, dynamic>);
}
