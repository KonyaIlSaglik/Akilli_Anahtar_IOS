import 'dart:convert';

import 'package:intl/intl.dart';

class NotificationModel {
  int? userId;
  int? deviceId;
  int? status;
  DateTime? datetime;

  NotificationModel({
    this.userId,
    this.deviceId,
    this.status,
    this.datetime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'deviceId': deviceId,
      'status': status,
      'datetime': datetime != null
          ? DateFormat("dd.MM.yyyy HH:mm:ss").format(datetime!)
          : null,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      userId: map['userId'] != null ? map['userId'] as int : null,
      deviceId: map['deviceId'] != null ? map['deviceId'] as int : null,
      status: map['status'] != null ? map['status'] as int : null,
      datetime: map['datetime'] != null
          ? DateFormat("dd.MM.yyyy HH:mm:ss")
              .tryParse(map['datetime'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
