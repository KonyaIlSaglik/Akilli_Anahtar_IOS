// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/entities/relay.dart';
import 'package:akilli_anahtar/entities/sensor.dart';

class BoxWithDevices {
  Box box;
  List<Relays> relays;
  List<Sensors> sensors;
  BoxWithDevices({
    required this.box,
    required this.relays,
    required this.sensors,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'box': box.toMap(),
      'relays': relays.map((x) => x.toMap()).toList(),
      'sensors': sensors.map((x) => x.toMap()).toList(),
    };
  }

  factory BoxWithDevices.fromMap(Map<String, dynamic> map) {
    return BoxWithDevices(
      box: Box.fromMap(map['box'] as Map<String, dynamic>),
      relays: List<Relays>.from(
        (map['relays'] as List<int>).map<Relays>(
          (x) => Relays.fromMap(x as Map<String, dynamic>),
        ),
      ),
      sensors: List<Sensors>.from(
        (map['sensors'] as List<int>).map<Sensors>(
          (x) => Sensors.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory BoxWithDevices.fromJson(String source) =>
      BoxWithDevices.fromMap(json.decode(source) as Map<String, dynamic>);
}
