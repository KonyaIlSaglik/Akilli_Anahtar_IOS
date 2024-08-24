import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SensorMessage {
  int id;
  int sensorId;
  double value;
  DateTime? dateTime;
  SensorMessage({
    this.id = 0,
    this.sensorId = 0,
    this.value = 0,
    this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sensorId': sensorId,
      'value': value,
      'dateTime': dateTime?.millisecondsSinceEpoch,
    };
  }

  factory SensorMessage.fromMap(Map<String, dynamic> map) {
    return SensorMessage(
      id: map['id'] as int,
      sensorId: map['sensorId'] as int,
      value: map['value'] as double,
      dateTime: map['dateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SensorMessage.fromJson(String source) =>
      SensorMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}
