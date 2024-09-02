import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/sensor_value_range.dart';
import 'dart:convert';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SensorValueRangeService {
  static String url = "$apiUrlOut/SensorValueRange";
  static Future<SensorValueRange?> get(int id) async {
    var uri = Uri.parse("$url/get?id=$id");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
    );
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      var sensorValueRange =
          SensorValueRange.fromJson(json.encode(result["data"]));
      return sensorValueRange;
    }
    return null;
  }

  static Future<List<SensorValueRange>?> getAll() async {
    var uri = Uri.parse("$url/getall");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
    );
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      var sensorValueRangeList = List<SensorValueRange>.from(
          (result["data"] as List<dynamic>)
              .map((e) => SensorValueRange.fromJson(json.encode(e))));
      return sensorValueRangeList;
    }
    return null;
  }

  static Future<Result> add(SensorValueRange sensorValueRange) async {
    var uri = Uri.parse("$url/add");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
      body: sensorValueRange.toJson(),
    );
    client.close();
    var result = Result();
    if (response.statusCode == 200) {
      var body = json.decode(response.body) as Map<String, dynamic>;
      result.success = body["success"] as bool;
      result.message = body["message"] ?? "";
    }
    return result;
  }

  static Future<Result> update(SensorValueRange sensorValueRange) async {
    var uri = Uri.parse("$url/update");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.put(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
      body: sensorValueRange.toJson(),
    );
    client.close();
    var result = Result();
    if (response.statusCode == 200) {
      var body = json.decode(response.body) as Map<String, dynamic>;
      result.success = body["success"] as bool;
      result.message = body["message"] ?? "";
    }
    return result;
  }
}
