import 'dart:convert';

import 'package:akilli_anahtar/models/box_with_devices.dart';

class NodemcuInfoModel {
  String chipId;
  String wifiSsid;
  String wifiPassword;
  bool wifiConnected;
  String localIp;
  String serviceInfo;
  bool serviceConnected;
  BoxWithDevices? boxWithDevices;
  String version;
  NodemcuInfoModel({
    this.chipId = "",
    this.wifiSsid = "",
    this.wifiPassword = "",
    this.wifiConnected = false,
    this.localIp = "",
    this.serviceInfo = "",
    this.serviceConnected = false,
    this.boxWithDevices,
    this.version = "",
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chip_id': chipId,
      'wifi_ssid': wifiSsid,
      'wifi_password': wifiPassword,
      'wifi_connected': wifiConnected,
      'local_ip': localIp,
      'service_info': serviceInfo,
      'service_connected': serviceConnected,
      'box': boxWithDevices,
      'version': version,
    };
  }

  factory NodemcuInfoModel.fromMap(Map<String, dynamic> map) {
    return NodemcuInfoModel(
      chipId: map['chip_id'] != null ? map['chip_id'] as String : "",
      wifiSsid: map['wifi_ssid'] != null ? map['wifi_ssid'] as String : "",
      wifiPassword:
          map['wifi_password'] != null ? map['wifi_password'] as String : "",
      wifiConnected:
          map['wifi_connected'] != null ? map['wifi_connected'] as bool : false,
      localIp: map['local_ip'] != null ? map['local_ip'] as String : "",
      serviceInfo:
          map['service_info'] != null ? map['service_info'] as String : "",
      serviceConnected: map['service_connected'] != null
          ? map['service_connected'] as bool
          : false,
      boxWithDevices: BoxWithDevices.fromMap(map["box"]),
      version: map['version'] != null ? map['version'] as String : "",
    );
  }

  String toJson() => json.encode(toMap());

  factory NodemcuInfoModel.fromJson(String source) =>
      NodemcuInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
