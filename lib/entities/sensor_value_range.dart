import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SensorValueRange {
  int id;
  int sensorId;
  int minValue;
  int maxValue;
  DateTime? insertDatetime;
  SensorValueRange({
    this.id = 0,
    this.sensorId = 0,
    this.minValue = 0,
    this.maxValue = 0,
    this.insertDatetime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sensorId': sensorId,
      'minValue': minValue,
      'maxValue': maxValue,
      'insertDatetime': insertDatetime,
    };
  }

  factory SensorValueRange.fromMap(Map<String, dynamic> map) {
    return SensorValueRange(
      id: map['id'] as int,
      sensorId: map['sensorId'] as int,
      minValue: map['minValue'] as int,
      maxValue: map['maxValue'] as int,
      insertDatetime:
          DateTime.tryParse(map['insertDatetime']) ?? DateTime(1900),
    );
  }

  String toJson() => json.encode(toMap());

  factory SensorValueRange.fromJson(String source) =>
      SensorValueRange.fromMap(json.decode(source) as Map<String, dynamic>);
}
