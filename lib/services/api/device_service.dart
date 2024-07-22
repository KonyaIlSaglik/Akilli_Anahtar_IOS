import 'dart:convert';

import 'package:akilli_anahtar/models/kullanici_kapi.dart';
import 'package:akilli_anahtar/models/kullanici_sensor.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:http/http.dart' as http;

class DeviceService {
  static String url = "${apiUrlOut}Device";

  static Future<List<KullaniciKapi>?> getKullaniciKapi(int id) async {
    var uri = Uri.parse("$url/kullanicikapi?userId=$id");
    var client = http.Client();
    var response = await client.post(uri);
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      print(json.encode(result["data"]));
      var kapilar =
          KullaniciKapi.kullaniciKapiFromJson(json.encode(result["data"]));
      return kapilar;
    }
    return null;
  }

  static Future<List<KullaniciSensor>?> getKullaniciSensor(int id) async {
    var uri = Uri.parse("$url/kullanicisensor?userId=$id");
    var client = http.Client();
    var response = await client.post(uri);
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      print(json.encode(result["data"]));
      var sensorler =
          KullaniciSensor.kullaniciSensorFromJson(json.encode(result["data"]));
      return sensorler;
    }
    return null;
  }
}
