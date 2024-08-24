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
      id: map['id'] as int,
      userId: map['userId'] as int,
      deviceId: map['deviceId'] as int,
      deviceTypeId: map['deviceTypeId'] as int,
      boxId: map['boxId'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDevice.fromJson(String source) =>
      UserDevice.fromMap(json.decode(source) as Map<String, dynamic>);
}
