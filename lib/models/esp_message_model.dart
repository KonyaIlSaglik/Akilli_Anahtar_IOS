// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class EspMessageModel {
  int deviceId;
  double deger;
  int alarm;
  String referance;

  EspMessageModel({
    required this.deviceId,
    required this.deger,
    required this.alarm,
    required this.referance,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'device_id': deviceId,
      'deger': deger,
      'alarm': alarm,
      'referance': referance,
    };
  }

  factory EspMessageModel.fromMap(Map<String, dynamic> map) {
    return EspMessageModel(
      deviceId: map['device_id'] as int,
      deger: map['deger'] as double,
      alarm: map['alarm'] as int,
      referance: map['referance'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory EspMessageModel.fromJson(String source) =>
      EspMessageModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
