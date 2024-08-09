import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class DeviceType {
  int id;
  String name;
  int menuId;
  DeviceType({
    this.id = 0,
    this.name = "",
    this.menuId = 0,
  });

  static List<DeviceType> fromJsonList(String source) => List<DeviceType>.from(
      json.decode(source).map((x) => DeviceType.fromJson(json.encode(x))));

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'menuId': menuId,
    };
  }

  factory DeviceType.fromMap(Map<String, dynamic> map) {
    return DeviceType(
      id: map['id'] as int,
      name: map['name'] as String,
      menuId: map['menuId'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceType.fromJson(String source) =>
      DeviceType.fromMap(json.decode(source) as Map<String, dynamic>);
}
