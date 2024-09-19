// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/models/control_device_model.dart';
import 'package:akilli_anahtar/models/sensor_device_model.dart';

class BoxWithDevices {
  Box? box;
  List<ControlDeviceModel>? controlDeviceModels;
  List<SensorDeviceModel>? sensorDeviceModels;
  BoxWithDevices({
    this.box,
    this.controlDeviceModels,
    this.sensorDeviceModels,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'box': box?.toMap(),
      'controlDeviceModels':
          controlDeviceModels?.map((x) => x.toMap()).toList(),
      'sensorDeviceModels': sensorDeviceModels?.map((x) => x.toMap()).toList(),
    };
  }

  factory BoxWithDevices.fromMap(Map<String, dynamic> map) {
    return BoxWithDevices(
      box: Box.fromMap(map['box'] as Map<String, dynamic>),
      controlDeviceModels: List<ControlDeviceModel>.from(
        (map['controlDeviceModels'] as List<dynamic>).map<ControlDeviceModel>(
          (x) => ControlDeviceModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      sensorDeviceModels: List<SensorDeviceModel>.from(
        (map['sensorDeviceModels'] as List<dynamic>).map<SensorDeviceModel>(
          (x) => SensorDeviceModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory BoxWithDevices.fromJson(String source) =>
      BoxWithDevices.fromMap(json.decode(source) as Map<String, dynamic>);
}
