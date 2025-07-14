import 'dart:convert';

class NodemcuConnectionModel {
  int wifiMode;
  String? apSsid;
  String? apPass;
  String? apIp;
  String? apGateway;
  String? apNetmask;
  String? wifiSsid;
  String? wifiPass;
  String? apiHost;

  NodemcuConnectionModel({
    this.wifiMode = 2,
    this.apSsid,
    this.apPass,
    this.apIp,
    this.apGateway,
    this.apNetmask,
    this.wifiSsid,
    this.wifiPass,
    this.apiHost,
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
      'apiHost': apiHost,
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
      apiHost: map['apiHost'] != null ? map['apiHost'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NodemcuConnectionModel.fromJson(String source) =>
      NodemcuConnectionModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
