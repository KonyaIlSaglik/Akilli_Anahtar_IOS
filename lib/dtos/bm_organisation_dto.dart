import 'dart:convert';

class BmOrganisationDto {
  int? id;
  String? name;

  BmOrganisationDto({
    this.id,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory BmOrganisationDto.fromMap(Map<String, dynamic> map) {
    return BmOrganisationDto(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] != null ? map['name'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BmOrganisationDto.fromJson(String source) =>
      BmOrganisationDto.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<BmOrganisationDto> fromJsonList(String source) =>
      List<BmOrganisationDto>.from((json.decode(source) as List<dynamic>)
          .map((x) => BmOrganisationDto.fromJson(json.encode(x))));
}
