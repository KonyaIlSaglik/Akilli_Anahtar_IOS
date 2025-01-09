import 'dart:convert';

class UmDeviceDto {
  int? id;
  String? name;
  int? typeId;
  String? typeName;
  int? boxId;
  String? boxName;
  int? organisationId;
  String? organisationName;
  bool? userAdded;

  UmDeviceDto({
    this.id,
    this.name,
    this.typeId,
    this.typeName,
    this.boxId,
    this.boxName,
    this.organisationId,
    this.organisationName,
    this.userAdded,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'typeId': typeId,
      'typeName': typeName,
      'boxId': boxId,
      'boxName': boxName,
      'organisationId': organisationId,
      'organisationName': organisationName,
      'userAdded': userAdded,
    };
  }

  factory UmDeviceDto.fromMap(Map<String, dynamic> map) {
    return UmDeviceDto(
      id: map['id'] as int,
      name: map['name'] as String,
      typeId: map['typeId'] as int,
      typeName: map['typeName'] != null ? map['typeName'] as String : null,
      boxId: map['boxId'] as int,
      boxName: map['boxName'] != null ? map['boxName'] as String : null,
      organisationId:
          map['organisationId'] != null ? map['organisationId'] as int : null,
      organisationName: map['organisationName'] != null
          ? map['organisationName'] as String
          : null,
      userAdded: map['userAdded'] != null ? map['userAdded'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UmDeviceDto.fromJson(String source) =>
      UmDeviceDto.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<UmDeviceDto> fromJsonList(String source) =>
      List<UmDeviceDto>.from((json.decode(source) as List<dynamic>)
          .map((x) => UmDeviceDto.fromJson(json.encode(x))));
}
