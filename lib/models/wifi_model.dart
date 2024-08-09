// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class WifiModel {
  String ssid;
  String password;
  WifiModel({
    required this.ssid,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'wifi_ssid': ssid,
      'wifi_password': password,
    };
  }

  factory WifiModel.fromMap(Map<String, dynamic> map) {
    return WifiModel(
      ssid: map['wifi_ssid'] as String,
      password: map['wifi_password'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory WifiModel.fromJson(String source) =>
      WifiModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
