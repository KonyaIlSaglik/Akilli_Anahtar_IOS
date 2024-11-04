import 'dart:convert';

class DeviceType {
  int id;
  String name;
  int menuId;
  DeviceType({
    this.id = 0,
    this.name = "",
    this.menuId = 0,
  });

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

  static List<DeviceType> fromJsonList(String source) =>
      List<DeviceType>.from((json.decode(source) as List<dynamic>)
          .map((x) => DeviceType.fromJson(json.encode(x))));
}
