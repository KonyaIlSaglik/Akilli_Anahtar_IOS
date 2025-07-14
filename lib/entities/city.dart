import 'dart:convert';

class City {
  int id;
  String name;
  City({
    this.id = 0,
    this.name = "",
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory City.fromJson(String source) =>
      City.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<City> fromJsonList(String source) =>
      List<City>.from((json.decode(source) as List<dynamic>)
          .map((x) => City.fromJson(json.encode(x))));
}
