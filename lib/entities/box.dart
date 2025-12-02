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
  String localIp;
  int restartTimeout;
  String? espType;
  int? channel;
  int? boxTypeId;
  int? target;
  //bool isSub = false;
  //String? organisationName;
  //int isOld = -1;
  //bool upgrading = false;
  //bool apEnable = false;

  Box({
    this.id = 0,
    this.name = "",
    this.chipId = 0,
    this.organisationId = 0,
    this.active = 1,
    this.topicRec = "",
    this.topicRes = "",
    this.version = "",
    this.localIp = "",
    this.restartTimeout = 0,
    this.espType,
    this.channel,
    this.boxTypeId,
    this.target,
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
      'localIp': localIp,
      'espType': espType,
      'channel': channel,
      'boxTypeId': boxTypeId,
      'target': target,
    };
  }

  factory Box.fromMap(Map<String, dynamic> map) {
    return Box(
      id: map['id'] ?? 0,
      name: map['name'] ?? "",
      chipId: map['chipId'] ?? 0,
      organisationId: map['organisationId'] ?? 0,
      active: map['active'] ?? 1,
      topicRec: map['topicRec'] ?? "",
      topicRes: map['topicRes'] ?? "",
      version: map['version'] ?? "",
      localIp: map['localIp'] ?? "",
      restartTimeout: map['restartTimeout'] ?? 0,
      espType: map['espType']?.toString(),
      channel: map['channel'],
      boxTypeId: map['boxTypeId'],
      target: map['target'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Box.fromJson(String source) =>
      Box.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<Box> fromJsonList(String source) =>
      List<Box>.from((json.decode(source) as List<dynamic>)
          .map((x) => Box.fromJson(json.encode(x))));
}
