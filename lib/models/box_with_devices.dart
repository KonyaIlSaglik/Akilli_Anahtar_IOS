// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/models/control_device_model.dart';
import 'package:akilli_anahtar/models/sensor_device_model.dart';

class BoxWithDevices {
  Box? box;
  List<ControlDeviceModel>? relays;
  List<SensorDeviceModel>? sensors;
  BoxWithDevices({
    this.box,
    this.relays,
    this.sensors,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'box': box?.toMap(),
      'relays': relays?.map((x) => x.toMap()).toList(),
      'sensors': sensors?.map((x) => x.toMap()).toList(),
    };
  }

  factory BoxWithDevices.fromMap(Map<String, dynamic> map) {
    return BoxWithDevices(
      box: Box.fromMap(map['box'] as Map<String, dynamic>),
      relays: List<ControlDeviceModel>.from(
        (map['relays'] as List<dynamic>).map<ControlDeviceModel>(
          (x) => ControlDeviceModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      sensors: List<SensorDeviceModel>.from(
        (map['sensors'] as List<dynamic>).map<SensorDeviceModel>(
          (x) => SensorDeviceModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory BoxWithDevices.fromJson(String source) =>
      BoxWithDevices.fromMap(json.decode(source) as Map<String, dynamic>);
}
