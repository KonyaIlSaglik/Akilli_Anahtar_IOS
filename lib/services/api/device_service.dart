import 'dart:convert';

import 'package:akilli_anahtar/models/box_with_devices.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:http/http.dart' as http;

class DeviceService {
  static String url = "${apiUrlOut}Device";

  static Future<BoxWithDevices?> getBoxDevices(int chipId) async {
    var uri = Uri.parse("$url/getboxwithdevicesbychipid?chip_id=$chipId");
    var client = http.Client();
    var response = await client.get(uri);
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      print(json.encode(result["data"]));
      var boxWithDevices = BoxWithDevices.fromJson(json.encode(result["data"]));
      return boxWithDevices;
    }
    return null;
  }

  static Future<List<BoxWithDevices>?> getUserDevices(int userId) async {
    var uri = Uri.parse("$url/getdevicesbyuserId?user_id=$userId");
    var client = http.Client();
    var response = await client.get(uri);
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      print(json.encode(result["data"]));
      var boxWithDevices = List<BoxWithDevices>.from(
        (result["data"] as List<dynamic>).map<BoxWithDevices>(
          (b) => BoxWithDevices.fromMap(b as Map<String, dynamic>),
        ),
      );
      return boxWithDevices;
    }
    return null;
  }
}
