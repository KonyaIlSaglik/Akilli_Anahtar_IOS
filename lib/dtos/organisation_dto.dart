import 'dart:convert';

class OrganisationDto {
  final int? id;
  final String name;
  final String? address;
  final int? cityId;
  final int? districtId;
  final int? type;
  final int? maxUserCount;
  final int? maxSessionCount;

  OrganisationDto({
    this.id,
    required this.name,
    this.address,
    this.cityId,
    this.districtId,
    this.type,
    this.maxUserCount,
    this.maxSessionCount,
  });

  static T? _pick<T>(Map<String, dynamic> json, String camel, String pascal) {
    final v = json[camel] ?? json[pascal];
    if (v == null) return null;
    return v as T;
  }

  factory OrganisationDto.fromJson(Map<String, dynamic> json) {
    return OrganisationDto(
      id: _pick<int>(json, 'id', 'Id'),
      name: (_pick<String>(json, 'name', 'Name') ?? ''),
      address: _pick<String>(json, 'address', 'Address'),
      cityId: _pick<int>(json, 'cityId', 'CityId'),
      districtId: _pick<int>(json, 'districtId', 'DistrictId'),
      type: _pick<int>(json, 'type', 'Type'),
      maxUserCount: _pick<int>(json, 'maxUserCount', 'MaxUserCount'),
      maxSessionCount: _pick<int>(json, 'maxSessionCount', 'MaxSessionCount'),
    );
  }

  Map<String, dynamic> toJson({bool forCreate = false}) {
    final map = <String, dynamic>{
      'name': name,
      'address': address,
      'cityId': cityId,
      'districtId': districtId,
      'type': type,
      'maxUserCount': maxUserCount,
      'maxSessionCount': maxSessionCount,
    };
    if (!forCreate && id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory OrganisationDto.fromJsonString(String source) =>
      OrganisationDto.fromJson(json.decode(source) as Map<String, dynamic>);
}
