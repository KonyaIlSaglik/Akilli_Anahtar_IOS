import 'dart:convert';

class SimpleOrganisationDto {
  final int organisationId;
  final String organisationName;

  SimpleOrganisationDto({
    required this.organisationId,
    required this.organisationName,
  });

  factory SimpleOrganisationDto.fromJson(Map<String, dynamic> json) {
    return SimpleOrganisationDto(
      organisationId: json['organisationId'],
      organisationName: json['organisationName'],
    );
  }

  static List<SimpleOrganisationDto> fromJsonList(String source) {
    final List<dynamic> data = json.decode(source);
    return data.map((e) => SimpleOrganisationDto.fromJson(e)).toList();
  }
}
