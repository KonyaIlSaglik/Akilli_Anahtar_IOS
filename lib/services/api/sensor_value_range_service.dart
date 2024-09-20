import 'package:akilli_anahtar/entities/sensor_value_range.dart';
import 'dart:convert';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class SensorValueRangeService {
  static String url = "$apiUrlOut/SensorValueRange";
  static Future<SensorValueRange?> get(int id) async {
    var response = await BaseService.get(url, id);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var sensorValueRange =
          SensorValueRange.fromJson(json.encode(result["data"]));
      return sensorValueRange;
    }
    return null;
  }

  static Future<List<SensorValueRange>?> getAll() async {
    var response = await BaseService.getAll(url);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var sensorValueRangeList = List<SensorValueRange>.from(
          (result["data"] as List<dynamic>)
              .map((e) => SensorValueRange.fromJson(json.encode(e))));
      return sensorValueRangeList;
    }
    return null;
  }

  static Future<Result> add(SensorValueRange sensorValueRange) async {
    return BaseService.add(url, sensorValueRange.toJson());
  }

  static Future<Result> update(SensorValueRange sensorValueRange) async {
    return BaseService.update(url, sensorValueRange.toJson());
  }

  static Future<Result> delete(int id) async {
    return BaseService.delete(url, id);
  }
}
