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
      'chip_id': chipId,
      'organisation_id': organisationId,
      'active': active,
      'topic_rec': topicRec,
      'topic_res': topicRes,
    };
  }

  factory Box.fromMap(Map<String, dynamic> map) {
    return Box(
      id: map['id'] as int,
      name: map['name'] as String,
      chipId: map['chip_id'] as int,
      organisationId: map['organisation_id'] as int,
      active: map['active'] as int,
      topicRec: map['topic_rec'] as String,
      topicRes: map['topic_res'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Box.fromJson(String source) =>
      Box.fromMap(json.decode(source) as Map<String, dynamic>);
}
