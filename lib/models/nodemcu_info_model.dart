// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:akilli_anahtar/models/box_with_devices.dart';

class NodemcuInfoModel {
  String hostName;
  String chipId;
  String macAddress;
  bool apEnable;
  String wifiSsid;
  String wifiPassword;
  String localIp;
  bool serviceConnected;
  String version;
  BoxWithDevices? devicesInfo;

  NodemcuInfoModel({
    this.hostName = "",
    this.chipId = "",
    this.macAddress = "",
    this.apEnable = false,
    this.wifiSsid = "",
    this.wifiPassword = "",
    this.localIp = "",
    this.serviceConnected = false,
    this.version = "",
    this.devicesInfo,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'hostName': hostName,
      'chipId': chipId,
      'macAddress': macAddress,
      'apEnable': apEnable,
      'wifiSsid': wifiSsid,
      'wifiPassword': wifiPassword,
      'localIp': localIp,
      'serviceConnected': serviceConnected,
      'version': version,
      'devicesInfo': devicesInfo?.toMap(),
    };
  }

  factory NodemcuInfoModel.fromMap(Map<String, dynamic> map) {
    return NodemcuInfoModel(
      hostName: map['hostName'] != null ? map['hostName'] as String : "",
      chipId: map['chipId'] != null ? map['chipId'] as String : "",
      macAddress: map['macAddress'] != null ? map['macAddress'] as String : "",
      apEnable: map['apEnable'] != null ? map['apEnable'] as bool : false,
      wifiSsid: map['wifiSsid'] != null ? map['wifiSsid'] as String : "",
      wifiPassword:
          map['wifiPassword'] != null ? map['wifiPassword'] as String : "",
      localIp: map['localIp'] != null ? map['localIp'] as String : "",
      serviceConnected: map['serviceConnected'] != null
          ? map['serviceConnected'] as bool
          : false,
      version: map['version'] != null ? map['version'] as String : "",
      devicesInfo: map['devicesInfo'] != null
          ? BoxWithDevices.fromMap(map['devicesInfo'] as Map<String, dynamic>)
          : BoxWithDevices(),
    );
  }

  String toJson() => json.encode(toMap());

  factory NodemcuInfoModel.fromJson(String source) =>
      NodemcuInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);
}


// 'box': boxWithDevices,


// boxWithDevices: map["box"] != null
//           ? BoxWithDevices.fromMap(map["box"])
//           : BoxWithDevices(),