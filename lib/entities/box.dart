import 'dart:convert';

class Box {
  int id;
  String name;
  int chipId;
  int organisationId;
  int active;
  String topicRec;
  String topicRes;
  String version;
  int restartTimeout;
  bool isSub = false;
  String? organisationName;
  int isOld = -1;
  bool upgrading = false;
  bool apEnable = false;

  Box({
    this.id = 0,
    this.name = "",
    this.chipId = 0,
    this.organisationId = 0,
    this.active = 1,
    this.topicRec = "",
    this.topicRes = "",
    this.version = "",
    this.restartTimeout = 0,
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
      'version': version,
      'restartTimeout': restartTimeout,
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
      version: map['version'] != null ? map['version'] as String : "",
      restartTimeout: map['restartTimeout'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Box.fromJson(String source) =>
      Box.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<Box> fromJsonList(String source) =>
      List<Box>.from((json.decode(source) as List<dynamic>)
          .map((x) => Box.fromJson(json.encode(x))));
}
