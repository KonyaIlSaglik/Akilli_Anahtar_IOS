import 'dart:convert';

import 'package:akilli_anahtar/models/box_with_devices.dart';
import 'package:akilli_anahtar/models/nodemcu_ap_model.dart';
import 'package:akilli_anahtar/models/nodemcu_info_model.dart';
import 'package:akilli_anahtar/models/mqtt_connection_model.dart';
import 'package:akilli_anahtar/models/wifi_model.dart';
import 'package:akilli_anahtar/services/api/device_service.dart';
import 'package:akilli_anahtar/services/api/parameter_service.dart';
import 'package:get/get.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;

class NodemcuController extends GetxController {
  var infoModel = NodemcuInfoModel().obs;
  var boxDevices = BoxWithDevices().obs;
  var apList = <NodemcuApModel>[].obs;
  var apSSID = "".obs;
  var apPass = "".obs;
  var apConnected = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await cleanNodemcu();
    await getNodemcuInfo();
  }

  Future<void> getNodemcuInfo() async {
    await WiFiForIoTPlugin.forceWifiUsage(true);
    var uri = Uri.parse("http://192.168.4.1/getinfo");
    var client = http.Client();
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      infoModel.value = NodemcuInfoModel.fromMap(result);
    }
  }

  Future<void> cleanNodemcu() async {
    await WiFiForIoTPlugin.forceWifiUsage(true);
    var uri = Uri.parse("http://192.168.4.1/cleandevices");
    var client = http.Client();
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      //
    }
  }

  Future<bool> sendDeviceSetting() async {
    await WiFiForIoTPlugin.forceWifiUsage(false);
    var result = await DeviceService.getBoxDevices(infoModel.value.chipId);
    if (result != null) {
      boxDevices.value = result;
    }
    await WiFiForIoTPlugin.forceWifiUsage(true);
    var uri = Uri.parse("http://192.168.4.1/devicesettings");
    var client = http.Client();
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json',
      },
      body: boxDevices.value.toJson(),
    );
    if (response.statusCode == 200) {
      await getNodemcuInfo();
    } else {
      // box
    }
    return false;
  }

  Future<void> getNodemcuApList() async {
    await WiFiForIoTPlugin.forceWifiUsage(true);
    var uri = Uri.parse("http://192.168.4.1/getaplist");
    var client = http.Client();
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      print(response.body);
      var result = json.decode(response.body) as List<dynamic>;
      List<Map<String, dynamic>> dataList = result.cast<Map<String, dynamic>>();
      apList.value = List<NodemcuApModel>.from(
        (dataList).map<NodemcuApModel>(
          (b) => NodemcuApModel.fromMap(b),
        ),
      );
    }
  }

  Future<void> sendWifiSettings() async {
    var wifiModel = WifiModel(ssid: apSSID.value, password: apPass.value);
    await WiFiForIoTPlugin.forceWifiUsage(true);
    var uri = Uri.parse("http://192.168.4.1/wifisettings");
    var client = http.Client();
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json',
      },
      body: wifiModel.toJson(),
    );
    if (response.statusCode == 200) {
      apConnected.value = response.body.contains("IP");
      await sendMqttSettings();
    }
  }

  Future<void> sendMqttSettings() async {
    await WiFiForIoTPlugin.forceWifiUsage(false);
    var parameters = await ParameterService.getParametersbyType(1);
    if (parameters != null) {
      var mqttModel = MqttConnectionModel.fromParameterList(parameters);
      mqttModel.mqttClientId = "AA${infoModel.value.chipId}";
      await WiFiForIoTPlugin.forceWifiUsage(true);
      var uri = Uri.parse("http://192.168.4.1/mqttsettings");
      var client = http.Client();
      var response = await client.post(
        uri,
        headers: {
          'content-type': 'application/json',
        },
        body: mqttModel.toJson(),
      );
      if (response.statusCode == 200) {
        //
      }
    }
  }
}
