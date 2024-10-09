// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserDevice {
  int id;
  int userId;
  int deviceId;
  int deviceTypeId;
  int boxId;
  UserDevice({
    this.id = 0,
    this.userId = 0,
    this.deviceId = 0,
    this.deviceTypeId = 0,
    this.boxId = 0,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'deviceId': deviceId,
      'deviceTypeId': deviceTypeId,
      'boxId': boxId,
    };
  }

  factory UserDevice.fromMap(Map<String, dynamic> map) {
    return UserDevice(
      id: map['id'] != null ? map['id'] as int : 0,
      userId: map['userId'] != null ? map['userId'] as int : 0,
      deviceId: map['deviceId'] != null ? map['deviceId'] as int : 0,
      deviceTypeId:
          map['deviceTypeId'] != null ? map['deviceTypeId'] as int : 0,
      boxId: map['boxId'] != null ? map['boxId'] as int : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDevice.fromJson(String source) =>
      UserDevice.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<UserDevice> fromJsonList(String source) =>
      List<UserDevice>.from((json.decode(source) as List<dynamic>)
          .map((x) => UserDevice.fromJson(json.encode(x))));

  UserDevice copyWith({
    int? id,
    int? userId,
    int? deviceId,
    int? deviceTypeId,
    int? boxId,
  }) {
    return UserDevice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      deviceTypeId: deviceTypeId ?? this.deviceTypeId,
      boxId: boxId ?? this.boxId,
    );
  }
}
