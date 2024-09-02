import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class NodemcuConnectionModel {
  int wifiMode;
  String? apSsid;
  String? apPass;
  String? apIp;
  String? apGateway;
  String? apNetmask;
  String? wifiSsid;
  String? wifiPass;
  String? mqttHostLocal;
  String? mqttHostPublic;
  int? mqttPort;
  String? mqttClientId;
  String? mqttUser;
  String? mqttPass;

  NodemcuConnectionModel({
    this.wifiMode = 2,
    this.apSsid,
    this.apPass,
    this.apIp,
    this.apGateway,
    this.apNetmask,
    this.wifiSsid,
    this.wifiPass,
    this.mqttHostLocal,
    this.mqttHostPublic,
    this.mqttPort,
    this.mqttClientId,
    this.mqttUser,
    this.mqttPass,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'wifiMode': wifiMode,
      'apSsid': apSsid,
      'apPass': apPass,
      'apIp': apIp,
      'apGateway': apGateway,
      'apNetmask': apNetmask,
      'wifiSsid': wifiSsid,
      'wifiPass': wifiPass,
      'mqttHostLocal': mqttHostLocal,
      'mqttHostPublic': mqttHostPublic,
      'mqttPort': mqttPort,
      'mqttClientId': mqttClientId,
      'mqttUser': mqttUser,
      'mqttPass': mqttPass,
    };
  }

  factory NodemcuConnectionModel.fromMap(Map<String, dynamic> map) {
    return NodemcuConnectionModel(
      wifiMode: map['wifiMode'] as int,
      apSsid: map['apSsid'] != null ? map['apSsid'] as String : null,
      apPass: map['apPass'] != null ? map['apPass'] as String : null,
      apIp: map['apIp'] != null ? map['apIp'] as String : null,
      apGateway: map['apGateway'] != null ? map['apGateway'] as String : null,
      apNetmask: map['apNetmask'] != null ? map['apNetmask'] as String : null,
      wifiSsid: map['wifiSsid'] != null ? map['wifiSsid'] as String : null,
      wifiPass: map['wifiPass'] != null ? map['wifiPass'] as String : null,
      mqttHostLocal:
          map['mqttHostLocal'] != null ? map['mqttHostLocal'] as String : null,
      mqttHostPublic: map['mqttHostPublic'] != null
          ? map['mqttHostPublic'] as String
          : null,
      mqttPort: map['mqttPort'] != null ? map['mqttPort'] as int : null,
      mqttClientId:
          map['mqttClientId'] != null ? map['mqttClientId'] as String : null,
      mqttUser: map['mqttUser'] != null ? map['mqttUser'] as String : null,
      mqttPass: map['mqttPass'] != null ? map['mqttPass'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NodemcuConnectionModel.fromJson(String source) =>
      NodemcuConnectionModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
