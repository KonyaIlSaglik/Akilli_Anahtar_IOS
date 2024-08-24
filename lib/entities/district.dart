import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
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
}
