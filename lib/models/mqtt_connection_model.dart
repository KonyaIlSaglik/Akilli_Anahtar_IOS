import 'dart:convert';

import 'package:akilli_anahtar/entities/parameter.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class MqttConnectionModel {
  String mqttHostLocal;
  String mqttHostPublic;
  int mqttPort;
  String mqttUser;
  String mqttPassword;
  String mqttClientId;

  MqttConnectionModel({
    required this.mqttHostLocal,
    required this.mqttHostPublic,
    required this.mqttPort,
    required this.mqttUser,
    required this.mqttPassword,
    required this.mqttClientId,
  });

  factory MqttConnectionModel.fromParameterList(List<Parameter> parameters) {
    return MqttConnectionModel(
      mqttHostLocal:
          parameters.firstWhere((p) => p.name == "mqtt_host_local").value,
      mqttHostPublic:
          parameters.firstWhere((p) => p.name == "mqtt_host_public").value,
      mqttPort: int.tryParse(
              parameters.firstWhere((p) => p.name == "mqtt_port").value) ??
          1883,
      mqttUser: parameters.firstWhere((p) => p.name == "mqtt_user").value,
      mqttPassword:
          parameters.firstWhere((p) => p.name == "mqtt_password").value,
      mqttClientId: "",
      // devices != null
      //     ? "${devices.box.id}-${devices.box.name}"
      //     : "AA$chipId",
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'mqtt_host_local': mqttHostLocal,
      'mqtt_host_public': mqttHostPublic,
      'mqtt_port': mqttPort,
      'mqtt_user': mqttUser,
      'mqtt_password': mqttPassword,
      "mqtt_client_id": mqttClientId,
    };
  }

  factory MqttConnectionModel.fromMap(Map<String, dynamic> map) {
    return MqttConnectionModel(
      mqttHostLocal: map['mqtt_host_local'] as String,
      mqttHostPublic: map['mqtt_host_public'] as String,
      mqttPort: map['mqtt_port'] as int,
      mqttUser: map['mqtt_user'] as String,
      mqttPassword: map['mqtt_password'] as String,
      mqttClientId: map["mqtt_client_id"] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MqttConnectionModel.fromJson(String source) =>
      MqttConnectionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
