import 'dart:convert';

class NodemcuInfoModel {
  String api;
  String chip;
  String mac;
  bool ap;
  String ssid;
  String pass;
  String ip;
  bool mqtt;
  String ver;

  NodemcuInfoModel({
    this.api = "",
    this.chip = "",
    this.mac = "",
    this.ap = false,
    this.ssid = "",
    this.pass = "",
    this.ip = "",
    this.mqtt = false,
    this.ver = "",
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'api': api,
      'chip': chip,
      'mac': mac,
      'ap': ap,
      'ssid': ssid,
      'pass': pass,
      'ip': ip,
      'mqtt': mqtt,
      'ver': ver,
    };
  }

  factory NodemcuInfoModel.fromMap(Map<String, dynamic> map) {
    return NodemcuInfoModel(
      api: map['api'] != null ? map['api'] as String : "",
      chip: map['chip'] != null ? map['chip'] as String : "",
      mac: map['mac'] != null ? map['mac'] as String : "",
      ap: map['ap'] != null ? map['ap'] as bool : false,
      ssid: map['ssid'] != null ? map['ssid'] as String : "",
      pass: map['pass'] != null ? map['pass'] as String : "",
      ip: map['ip'] != null ? map['ip'] as String : "",
      mqtt: map['mqtt'] != null ? map['mqtt'] as bool : false,
      ver: map['ver'] != null ? map['ver'] as String : "",
    );
  }

  String toJson() => json.encode(toMap());

  factory NodemcuInfoModel.fromJson(String source) =>
      NodemcuInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
