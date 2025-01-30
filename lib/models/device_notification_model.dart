// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DeviceNotificationModel {
  static String? on;
  static String off = "0";
  static String dk30 = "30";
  static String dk120 = "120";
  static String dk480 = "480";

  int deviceId;
  String? status;
  DateTime? dateTime;
  DeviceNotificationModel({
    required this.deviceId,
    this.status,
    this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'deviceId': deviceId,
      'status': status,
      'dateTime': dateTime?.millisecondsSinceEpoch,
    };
  }

  factory DeviceNotificationModel.fromMap(Map<String, dynamic> map) {
    return DeviceNotificationModel(
      deviceId: map['deviceId'] as int,
      status: map['status'] as String,
      dateTime: map['dateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceNotificationModel.fromJson(String source) =>
      DeviceNotificationModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
