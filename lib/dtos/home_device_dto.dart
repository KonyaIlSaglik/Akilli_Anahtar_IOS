import 'dart:convert';

class HomeDeviceDto {
  int? id;
  String? name;
  int? favoriteSequence;
  String? favoriteName;
  int? typeId;
  String? typeName;
  String? boxName;
  String? organisationName;
  String? topicStat;
  String? topicRec;
  String? topicRes;
  List<String>? rfCodes;
  String? unit;
  double? normalMinValue;
  double? normalMaxValue;
  double? criticalMinValue;
  double? criticalMaxValue;
  int? openingTime;
  int? waitingTime;
  int? closingTime;

  HomeDeviceDto({
    this.id,
    this.name,
    this.favoriteSequence,
    this.favoriteName,
    this.typeId,
    this.typeName,
    this.boxName,
    this.organisationName,
    this.topicStat,
    this.topicRec,
    this.topicRes,
    this.rfCodes,
    this.unit,
    this.normalMinValue,
    this.normalMaxValue,
    this.criticalMinValue,
    this.criticalMaxValue,
    this.openingTime,
    this.waitingTime,
    this.closingTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'favoriteSequence': favoriteSequence,
      'favoriteName': favoriteName,
      'typeId': typeId,
      'typeName': typeName,
      'boxName': boxName,
      'organisationName': organisationName,
      'topicStat': topicStat,
      'topicRec': topicRec,
      'topicRes': topicRes,
      'rfCodes': rfCodes,
      'unit': unit,
      'normalMinValue': normalMinValue,
      'normalMaxValue': normalMaxValue,
      'criticalMinValue': criticalMinValue,
      'criticalMaxValue': criticalMaxValue,
      'openingTime': openingTime,
      'waitingTime': waitingTime,
      'closingTime': closingTime,
    };
  }

  factory HomeDeviceDto.fromMap(Map<String, dynamic> map) {
    return HomeDeviceDto(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] != null ? map['name'] as String : null,
      favoriteSequence: map['favoriteSequence'] != null
          ? map['favoriteSequence'] as int
          : null,
      favoriteName:
          map['favoriteName'] != null ? map['favoriteName'] as String : null,
      typeId: map['typeId'] as int,
      typeName: map['typeName'] != null ? map['typeName'] as String : null,
      boxName: map['boxName'] != null ? map['boxName'] as String : null,
      organisationName: map['organisationName'] != null
          ? map['organisationName'] as String
          : null,
      topicStat: map['topicStat'] as String,
      topicRec: map['topicRec'] != null ? map['topicRec'] as String : null,
      topicRes: map['topicRes'] != null ? map['topicRes'] as String : null,
      rfCodes: (map['rfCodes'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
      unit: map['unit'] != null ? map['unit'] as String : null,
      normalMinValue: map['normalMinValue'] != null
          ? double.tryParse(map['normalMinValue'].toString()) ?? 0.0
          : null,
      normalMaxValue: map['normalMaxValue'] != null
          ? double.tryParse(map['normalMaxValue'].toString()) ?? 0.0
          : null,
      criticalMinValue: map['criticalMinValue'] != null
          ? double.tryParse(map['criticalMinValue'].toString()) ?? 0.0
          : null,
      criticalMaxValue: map['criticalMaxValue'] != null
          ? double.tryParse(map['criticalMaxValue'].toString()) ?? 0.0
          : null,
      openingTime:
          map['openingTime'] != null ? map['openingTime'] as int : null,
      waitingTime:
          map['waitingTime'] != null ? map['waitingTime'] as int : null,
      closingTime:
          map['closingTime'] != null ? map['closingTime'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory HomeDeviceDto.fromJson(String source) =>
      HomeDeviceDto.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<HomeDeviceDto> fromJsonList(String source) =>
      List<HomeDeviceDto>.from((json.decode(source) as List<dynamic>)
          .map((x) => HomeDeviceDto.fromJson(json.encode(x))));
}
