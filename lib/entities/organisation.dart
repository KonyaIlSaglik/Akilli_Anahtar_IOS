import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Organisation {
  int id;
  String name;
  String address;
  int cityId;
  int districtId;
  int type;
  int maxUserCount;
  int maxSessionCount;
  Organisation({
    this.id = 0,
    this.name = "",
    this.address = "",
    this.cityId = 0,
    this.districtId = 0,
    this.type = 0,
    this.maxUserCount = 0,
    this.maxSessionCount = 0,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'address': address,
      'cityId': cityId,
      'districtId': districtId,
      'type': type,
      'maxUserCount': maxUserCount,
      'maxSessionCount': maxSessionCount,
    };
  }

  factory Organisation.fromMap(Map<String, dynamic> map) {
    return Organisation(
      id: map['id'] as int,
      name: map['name'] as String,
      address: map['address'] as String,
      cityId: map['cityId'] as int,
      districtId: map['districtId'] as int,
      type: map['type'] != null ? map['type'] as int : 0,
      maxUserCount:
          map['maxUserCount'] != null ? map['maxUserCount'] as int : 0,
      maxSessionCount:
          map['maxSessionCount'] != null ? map['maxSessionCount'] as int : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Organisation.fromJson(String source) =>
      Organisation.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<Organisation> fromJsonList(String source) =>
      List<Organisation>.from((json.decode(source) as List<dynamic>)
          .map((x) => Organisation.fromJson(json.encode(x))));
}
