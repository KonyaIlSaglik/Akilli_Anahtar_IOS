import 'dart:convert';

import 'package:akilli_anahtar/models/nodemcu_ap_model.dart';
import 'package:akilli_anahtar/models/nodemcu_connection_model.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;

class NodemcuController extends GetxController {
  var connModel = NodemcuConnectionModel().obs;
  var apList = <NodemcuApModel>[].obs;
  var apScanning = false.obs;
  var wifiSSID = "".obs;
  var wifiPASS = "".obs;
  var uploading = false.obs;

  Future<void> createConnectionModel() async {
    connModel.value.wifiMode = wifiSSID.isEmpty ? 2 : 1;
    connModel.value.apIp = "192.168.4.1";
    connModel.value.apGateway = "192.168.4.1";
    connModel.value.apNetmask = "255.255.255.0";
    connModel.value.apiHost = apiUrlOut;
    connModel.value.wifiSsid = wifiSSID.value;
    connModel.value.wifiPass = wifiPASS.value;
  }

  Future<void> getNodemcuApList() async {
    var uri = Uri.parse("http://192.168.4.1/getaplist");
    var client = http.Client();
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as List<dynamic>;
      List<Map<String, dynamic>> dataList = result.cast<Map<String, dynamic>>();
      apList.value = List<NodemcuApModel>.from(
        (dataList).map<NodemcuApModel>(
          (b) => NodemcuApModel.fromMap(b),
        ),
      );
      apScanning.value = false;
    }
  }

  Future<void> sendConnectionSettings() async {
    createConnectionModel();
    var uri = Uri.parse("http://192.168.4.1/connectionsettings");
    var client = http.Client();
    await client.post(
      uri,
      headers: {
        'content-type': 'application/json',
      },
      body: connModel.toJson(),
    );
    uploading.value = false;
    await WiFiForIoTPlugin.forceWifiUsage(false);
  }
}
