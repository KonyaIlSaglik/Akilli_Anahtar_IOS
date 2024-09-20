import 'package:akilli_anahtar/entities/sensor.dart';
import 'dart:convert';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class SensorService {
  static String url = "$apiUrlOut/Sensor";
  static Future<Sensor?> get(int id) async {
    var response = await BaseService.get(url, id);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var sensor = Sensor.fromJson(json.encode(result["data"]));
      return sensor;
    }
    return null;
  }

  static Future<List<Sensor>?> getAll() async {
    var response = await BaseService.getAll(url);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var sensorList = List<Sensor>.from((result["data"] as List<dynamic>)
          .map((e) => Sensor.fromJson(json.encode(e))));
      return sensorList;
    }
    return null;
  }

  static Future<Result> add(Sensor sensor) async {
    return BaseService.add(url, sensor.toJson());
  }

  static Future<Result> update(Sensor sensor) async {
    return BaseService.update(url, sensor.toJson());
  }

  static Future<Result> delete(int id) async {
    return BaseService.delete(url, id);
  }
}
