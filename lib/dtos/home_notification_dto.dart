// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class HomeNotificationDto {
  int? id;
  int? sensorId;
  String? boxName;
  String? sensorName;
  int? typeId;
  double? value;
  DateTime? dateTime;
  int? alarmStatus;
  String? referance;
  HomeNotificationDto({
    this.id,
    this.sensorId,
    this.boxName,
    this.sensorName,
    this.typeId,
    this.value,
    this.dateTime,
    this.alarmStatus,
    this.referance,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sensorId': sensorId,
      'boxName': boxName,
      'sensorName': sensorName,
      'typeId': typeId,
      'value': value,
      'dateTime': dateTime.toString(),
      'alarmStatus': alarmStatus,
      'referance': referance,
    };
  }

  factory HomeNotificationDto.fromMap(Map<String, dynamic> map) {
    return HomeNotificationDto(
      id: map['id'] != null ? map['id'] as int : null,
      sensorId: map['sensorId'] != null ? map['sensorId'] as int : null,
      boxName: map['boxName'] != null ? map['boxName'] as String : null,
      sensorName:
          map['sensorName'] != null ? map['sensorName'] as String : null,
      typeId: map['typeId'] != null ? map['typeId'] as int : null,
      value: map['value'] != null ? (map['value'] as num).toDouble() : null,
      dateTime: map['dateTime'] != null
          ? DateTime.parse(map['dateTime'] as String)
          : null,
      alarmStatus:
          map['alarmStatus'] != null ? map['alarmStatus'] as int : null,
      referance: map['referance'] != null ? map['referance'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory HomeNotificationDto.fromJson(String source) =>
      HomeNotificationDto.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<HomeNotificationDto> fromJsonList(String source) {
    final List<dynamic> jsonList = json.decode(source) as List<dynamic>;
    return jsonList
        .map((x) => HomeNotificationDto.fromJson(json.encode(x)))
        .toList();
  }
}
