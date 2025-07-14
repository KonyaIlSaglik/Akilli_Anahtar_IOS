import 'dart:convert';

class UmOrganisationDto {
  int? id;
  String? name;
  bool? userAdded;

  UmOrganisationDto({
    this.id,
    this.name,
    this.userAdded,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'userAdded': userAdded,
    };
  }

  factory UmOrganisationDto.fromMap(Map<String, dynamic> map) {
    return UmOrganisationDto(
      id: map['id'] as int,
      name: map['name'] as String,
      userAdded: map['userAdded'] != null ? map['userAdded'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UmOrganisationDto.fromJson(String source) =>
      UmOrganisationDto.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<UmOrganisationDto> fromJsonList(String source) =>
      List<UmOrganisationDto>.from((json.decode(source) as List<dynamic>)
          .map((x) => UmOrganisationDto.fromJson(json.encode(x))));
}
