import 'dart:convert';

class Relay {
  int id;
  String name;
  int deviceTypeId;
  String topicStat;
  String topicRec;
  String topicRes;
  String? description;
  int boxId;
  String pin;
  int active;
  String? topicMessage;
  Relay({
    required this.id,
    required this.name,
    required this.deviceTypeId,
    required this.topicStat,
    required this.topicRec,
    required this.topicRes,
    this.description,
    required this.boxId,
    required this.pin,
    required this.active,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'device_type_id': deviceTypeId,
      'topic_stat': topicStat,
      'topic_rec': topicRec,
      'topic_res': topicRes,
      'description': description,
      'box_id': boxId,
      'pin': pin,
      'active': active,
    };
  }

  factory Relay.fromMap(Map<String, dynamic> map) {
    return Relay(
      id: map['id'] as int,
      name: map['name'] as String,
      deviceTypeId: map['device_type_id'] as int,
      topicStat: map['topic_stat'] as String,
      topicRec: map['topic_rec'] as String,
      topicRes: map['topic_res'] as String,
      description: map['description'] ?? "",
      boxId: map['box_id'] as int,
      pin: map['pin'] as String,
      active: map['active'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Relay.fromJson(String source) =>
      Relay.fromMap(json.decode(source) as Map<String, dynamic>);
}
