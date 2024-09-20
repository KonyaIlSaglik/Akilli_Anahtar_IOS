import 'package:akilli_anahtar/entities/sensor_message.dart';
import 'dart:convert';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class SensorMessageService {
  static String url = "$apiUrlOut/SensorMessage";
  static Future<SensorMessage?> get(int id) async {
    var response = await BaseService.get(url, id);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var sensorMessage = SensorMessage.fromJson(json.encode(result["data"]));
      return sensorMessage;
    }
    return null;
  }

  static Future<List<SensorMessage>?> getAll() async {
    var response = await BaseService.getAll(url);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var sensorMessageList = List<SensorMessage>.from(
          (result["data"] as List<dynamic>)
              .map((e) => SensorMessage.fromJson(json.encode(e))));
      return sensorMessageList;
    }
    return null;
  }

  static Future<Result> add(SensorMessage sensorMessage) async {
    return BaseService.add(url, sensorMessage.toJson());
  }

  static Future<Result> update(SensorMessage sensorMessage) async {
    return BaseService.update(url, sensorMessage.toJson());
  }

  static Future<Result> delete(int id) async {
    return BaseService.delete(url, id);
  }
}
