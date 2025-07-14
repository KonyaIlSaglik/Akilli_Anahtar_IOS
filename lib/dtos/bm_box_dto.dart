import 'dart:convert';

class BmBoxDto {
  int? id;
  String? name;
  int? chipId;
  int? organisationId;
  String? organisationName;
  int? active;
  String? topicRec;
  String? topicRes;
  String? version;
  String? localIp;
  int? restartTimeout;

  BmBoxDto({
    this.id,
    this.name,
    this.chipId,
    this.organisationId,
    this.organisationName,
    this.active,
    this.topicRec,
    this.topicRes,
    this.version,
    this.localIp,
    this.restartTimeout,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'chipId': chipId,
      'organisationId': organisationId,
      'organisationName': organisationName,
      'active': active,
      'topicRec': topicRec,
      'topicRes': topicRes,
      'version': version,
      'restartTimeout': restartTimeout,
    };
  }

  factory BmBoxDto.fromMap(Map<String, dynamic> map) {
    return BmBoxDto(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] != null ? map['name'] as String : null,
      chipId: map['chipId'] != null ? map['chipId'] as int : null,
      organisationId:
          map['organisationId'] != null ? map['organisationId'] as int : null,
      organisationName: map['organisationName'] != null
          ? map['organisationName'] as String
          : null,
      active: map['active'] != null ? map['active'] as int : null,
      topicRec: map['topicRec'] != null ? map['topicRec'] as String : null,
      topicRes: map['topicRes'] != null ? map['topicRes'] as String : null,
      version: map['version'] != null ? map['version'] as String : null,
      restartTimeout:
          map['restartTimeout'] != null ? map['restartTimeout'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BmBoxDto.fromJson(String source) =>
      BmBoxDto.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<BmBoxDto> fromJsonList(String source) =>
      List<BmBoxDto>.from((json.decode(source) as List<dynamic>)
          .map((x) => BmBoxDto.fromJson(json.encode(x))));
}
