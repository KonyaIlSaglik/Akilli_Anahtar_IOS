import 'dart:convert';

class Relays {
  int id;
  String name;
  int deviceTypeId;
  String topicStat;
  String topicRec;
  String topicRes;
  String description;
  int boxId;
  String pin;
  int active;
  Relays({
    required this.id,
    required this.name,
    required this.deviceTypeId,
    required this.topicStat,
    required this.topicRec,
    required this.topicRes,
    required this.description,
    required this.boxId,
    required this.pin,
    required this.active,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'deviceTypeId': deviceTypeId,
      'topicStat': topicStat,
      'topicRec': topicRec,
      'topicRes': topicRes,
      'description': description,
      'boxId': boxId,
      'pin': pin,
      'active': active,
    };
  }

  factory Relays.fromMap(Map<String, dynamic> map) {
    return Relays(
      id: map['id'] as int,
      name: map['name'] as String,
      deviceTypeId: map['deviceTypeId'] as int,
      topicStat: map['topicStat'] as String,
      topicRec: map['topicRec'] as String,
      topicRes: map['topicRes'] as String,
      description: map['description'] as String,
      boxId: map['boxId'] as int,
      pin: map['pin'] as String,
      active: map['active'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Relays.fromJson(String source) =>
      Relays.fromMap(json.decode(source) as Map<String, dynamic>);
}
