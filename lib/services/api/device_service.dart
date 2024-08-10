import 'dart:convert';

import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:akilli_anahtar/models/box_with_devices.dart';
import 'package:akilli_anahtar/models/control_device_model.dart';
import 'package:akilli_anahtar/models/sensor_device_model.dart';
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
      var boxWithDevices = BoxWithDevices.fromJson(json.encode(result["data"]));
      return boxWithDevices;
    }
    return null;
  }

  // static Future<List<BoxWithDevices>?> getUserDevices(int userId) async {
  //   var uri = Uri.parse("$url/getdevicesbyuserId?user_id=$userId");
  //   var client = http.Client();
  //   var response = await client.get(uri);
  //   client.close();
  //   if (response.statusCode == 200) {
  //     var result = json.decode(response.body) as Map<String, dynamic>;
  //     print(json.encode(result["data"]));
  //     var boxWithDevices = List<BoxWithDevices>.from(
  //       (result["data"] as List<dynamic>).map<BoxWithDevices>(
  //         (b) => BoxWithDevices.fromMap(b as Map<String, dynamic>),
  //       ),
  //     );
  //     return boxWithDevices;
  //   }
  //   return null;
  // }

  static Future<List<DeviceType>?> getDeviceTypes() async {
    var uri = Uri.parse("$url/getdevicetypes");
    var client = http.Client();
    var response = await client.get(uri);
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      var types = List<DeviceType>.from(
        (result["data"] as List<dynamic>).map<DeviceType>(
          (b) => DeviceType.fromMap(b as Map<String, dynamic>),
        ),
      );
      return types;
    }
    return null;
  }

  static Future<List<SensorDeviceModel>?> getSensorDevices(int userId) async {
    var uri = Uri.parse("$url/getsensordevicesbyuserid?user_id=$userId");
    var client = http.Client();
    var response = await client.get(uri);
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      var sensorDevices = List<SensorDeviceModel>.from(
        (result["data"] as List<dynamic>).map<SensorDeviceModel>(
          (b) => SensorDeviceModel.fromMap(b as Map<String, dynamic>),
        ),
      );
      return sensorDevices;
    }
    return null;
  }

  static Future<List<ControlDeviceModel>?> getControlDevices(
      int userId, int menuId) async {
    var uri = Uri.parse(
        "$url/getcontroldevicesbyuseridandmenuid?user_id=$userId&menu_id=$menuId");
    var client = http.Client();
    var response = await client.get(uri);
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      try {
        var controlDevices = List<ControlDeviceModel>.from(
          (result["data"] as List<dynamic>).map<ControlDeviceModel>(
            (b) => ControlDeviceModel.fromMap(b as Map<String, dynamic>),
          ),
        );
        return controlDevices;
      } catch (e) {
        print('Error parsing JSON: $e');
      }
      return null;
    }
    return null;
  }
}
