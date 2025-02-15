import 'dart:convert';

class SensorMessage {
  int? id;
  int? sensorId;
  double? value;
  DateTime? dateTime;
  int? alarmStatus;
  String? referance;
  SensorMessage({
    this.id = 0,
    this.sensorId = 0,
    this.value = 0,
    this.dateTime,
    this.alarmStatus,
    this.referance,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sensorId': sensorId,
      'value': value,
      'dateTime': dateTime?.millisecondsSinceEpoch,
      'alarmStatus': alarmStatus,
      'referance': referance
    };
  }

  factory SensorMessage.fromMap(Map<String, dynamic> map) {
    return SensorMessage(
      id: map['id'] as int?,
      sensorId: map['sensorId'] as int?,
      value: map['value'] != null
          ? double.tryParse(map['value'].toString())
          : null,
      dateTime: map['dateTime'] != null
          ? DateTime.tryParse(map['dateTime'].toString())
          : null,
      alarmStatus: map['alarmStatus'] as int?,
      referance: map['referance'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory SensorMessage.fromJson(String source) =>
      SensorMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}
