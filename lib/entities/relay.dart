// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  factory Relay.fromMap(Map<String, dynamic> map) {
    return Relay(
      id: map['id'] as int,
      name: map['name'] as String,
      deviceTypeId: map['deviceTypeId'] as int,
      topicStat: map['topicStat'] as String,
      topicRec: map['topicRec'] as String,
      topicRes: map['topicRes'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      boxId: map['boxId'] as int,
      pin: map['pin'] as String,
      active: map['active'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Relay.fromJson(String source) =>
      Relay.fromMap(json.decode(source) as Map<String, dynamic>);
}
