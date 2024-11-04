import 'dart:convert';

class District {
  int id;
  String name;
  int cityId;
  District({
    this.id = 0,
    this.name = "",
    this.cityId = 0,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'cityId': cityId,
    };
  }

  factory District.fromMap(Map<String, dynamic> map) {
    return District(
      id: map['id'] as int,
      name: map['name'] as String,
      cityId: map['cityId'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory District.fromJson(String source) =>
      District.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<District> fromJsonList(String source) =>
      List<District>.from((json.decode(source) as List<dynamic>)
          .map((x) => District.fromJson(json.encode(x))));
}
