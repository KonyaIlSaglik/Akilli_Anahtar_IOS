import 'dart:convert';

class Box {
  int id;
  String name;
  int chipId;
  int organisationId;
  int active;
  String topicRec;
  String topicRes;

  Box({
    required this.id,
    required this.name,
    required this.chipId,
    required this.organisationId,
    required this.active,
    required this.topicRec,
    required this.topicRes,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'chipId': chipId,
      'organisationId': organisationId,
      'active': active,
      'topicRec': topicRec,
      'topicRes': topicRes,
    };
  }

  factory Box.fromMap(Map<String, dynamic> map) {
    return Box(
      id: map['id'] as int,
      name: map['name'] as String,
      chipId: map['chipId'] as int,
      organisationId: map['organisationId'] as int,
      active: map['active'] as int,
      topicRec: map['topicRec'] as String,
      topicRes: map['topicRes'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Box.fromJson(String source) =>
      Box.fromMap(json.decode(source) as Map<String, dynamic>);
}
