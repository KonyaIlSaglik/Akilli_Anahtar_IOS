import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/entities/city.dart';
import 'package:akilli_anahtar/entities/district.dart';
import 'dart:convert';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CityService {
  static String url = "$apiUrlOut/City";
  static Future<City?> getCity(int id) async {
    var uri = Uri.parse("$url/getCity?id=$id");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var session = authController.session.value;
    var response = await client.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${session.accessToken}',
      },
    );
    client.close();
    if (response.statusCode == 200) {
      var city = City.fromJson(response.body);
      return city;
    }
    return null;
  }

  static Future<List<City>?> getAllCity() async {
    var uri = Uri.parse("$url/getAllCity");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var session = authController.session.value;
    var response = await client.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${session.accessToken}',
      },
    );
    client.close();
    if (response.statusCode == 200) {
      var cityList = City.fromJsonList(json.encode(response.body));
      return cityList;
    }
    return null;
  }

  static Future<District?> getDistrict(int id) async {
    var uri = Uri.parse("$url/getDistrict?id=$id");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var session = authController.session.value;
    var response = await client.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${session.accessToken}',
      },
    );
    client.close();
    if (response.statusCode == 200) {
      var district = District.fromJson(response.body);
      return district;
    }
    return null;
  }

  static Future<List<District>?> getAllDistrict() async {
    var uri = Uri.parse("$url/getAllDistrict");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var session = authController.session.value;
    var response = await client.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${session.accessToken}',
      },
    );
    client.close();
    if (response.statusCode == 200) {
      var districtList = District.fromJsonList(json.encode(response.body));
      return districtList;
    }
    return null;
  }
}
