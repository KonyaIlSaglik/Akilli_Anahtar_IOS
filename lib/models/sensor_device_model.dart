import 'dart:convert';

class SensorDeviceModel {
  int? id;
  String? name;
  int? deviceTypeId;
  String? topicStat;
  String? description;
  int? boxId;
  String? pin;
  int? active;
  String? unit;
  int? valueRangeId;
  double? valueRangeMin;
  double? valueRangeMax;
  String? deviceTypeName;
  int? deviceTypeMenuId;
  String? boxName;
  int? boxOrganisationId;
  String? boxOrganisationName;
  SensorDeviceModel({
    this.id,
    this.name,
    this.deviceTypeId,
    this.topicStat,
    this.description,
    this.boxId,
    this.pin,
    this.active,
    this.unit,
    this.valueRangeId,
    this.valueRangeMin,
    this.valueRangeMax,
    this.deviceTypeName,
    this.deviceTypeMenuId,
    this.boxName,
    this.boxOrganisationId,
    this.boxOrganisationName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'deviceTypeId': deviceTypeId,
      'topicStat': topicStat,
      'description': description,
      'boxId': boxId,
      'pin': pin,
      'active': active,
      'unit': unit,
      'valueRangeId': valueRangeId,
      'valueRangeMin': valueRangeMin,
      'valueRangeMax': valueRangeMax,
      'deviceTypeName': deviceTypeName,
      'deviceTypeMenuId': deviceTypeMenuId,
      'boxName': boxName,
      'boxOrganisationId': boxOrganisationId,
      'boxOrganisationName': boxOrganisationName,
    };
  }

  factory SensorDeviceModel.fromMap(Map<String, dynamic> map) {
    print(map);
    return SensorDeviceModel(
      id: map['id'] as int?,
      name: map['name'] as String?,
      deviceTypeId: map['deviceTypeId'] as int?,
      topicStat: map['topicStat'] as String?,
      description: map['description'] as String?,
      boxId: map['boxId'] as int?,
      pin: map['pin'] as String?,
      active: map['active'] as int?,
      unit: map['unit'] as String?,
      valueRangeId: map['valueRangeId'] as int?,
      valueRangeMin: (map['valueRangeMin'] is num)
          ? (map['valueRangeMin'] as num).toDouble()
          : null,
      valueRangeMax: (map['valueRangeMax'] is num)
          ? (map['valueRangeMax'] as num).toDouble()
          : null,
      deviceTypeName: map['deviceTypeName'] as String?,
      deviceTypeMenuId: map['deviceTypeMenuId'] as int?,
      boxName: map['boxName'] as String?,
      boxOrganisationId: map['boxOrganisationId'] as int?,
      boxOrganisationName: map['boxOrganisationName'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory SensorDeviceModel.fromJson(String source) =>
      SensorDeviceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
