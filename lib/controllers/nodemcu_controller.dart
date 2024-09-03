import 'dart:convert';

import 'package:akilli_anahtar/models/box_with_devices.dart';
import 'package:akilli_anahtar/models/nodemcu_ap_model.dart';
import 'package:akilli_anahtar/models/nodemcu_connection_model.dart';
import 'package:akilli_anahtar/services/api/device_service.dart';
import 'package:akilli_anahtar/services/api/parameter_service.dart';
import 'package:get/get.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;

class NodemcuController extends GetxController {
  var boxDevices = <BoxWithDevices>[].obs;
  var connModel = NodemcuConnectionModel().obs;
  var downloaded = false.obs;
  var chipId = "".obs;
  var selectedDevice = BoxWithDevices().obs;
  var apList = <NodemcuApModel>[].obs;
  var apScanning = false.obs;
  var wifiSSID = "".obs;
  var wifiPASS = "".obs;
  var uploading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await getDeviceList();
    await getConnModel();
  }

  Future<void> getDeviceList() async {
    var result = await DeviceService.getDevicesForInstall();
    if (result != null) {
      boxDevices.value = result;
    }
  }

  Future<void> getConnModel() async {
    connModel.value.wifiMode = 1;
    connModel.value.apSsid = "AKILLI_ANAHTAR";
    connModel.value.apPass = "AA123456";
    connModel.value.apIp = "192.168.4.1";
    connModel.value.apGateway = "192.168.4.1";
    connModel.value.apNetmask = "255.255.255.0";

    var params = await ParameterService.getParametersbyType(1);
    if (params != null) {
      connModel.value.mqttHostLocal =
          params.firstWhereOrNull((p) => p.name == "mqtt_host_local")!.value;
      connModel.value.mqttHostPublic =
          params.firstWhereOrNull((p) => p.name == "mqtt_host_public")!.value;
      connModel.value.mqttPort = int.tryParse(
              params.firstWhereOrNull((p) => p.name == "mqtt_port")!.value) ??
          1883;
      connModel.value.mqttUser =
          params.firstWhereOrNull((p) => p.name == "mqtt_user")!.value;
      connModel.value.mqttPass =
          params.firstWhereOrNull((p) => p.name == "mqtt_password")!.value;
    }
    downloaded.value = true;
  }

  Future<void> getChipId() async {
    await WiFiForIoTPlugin.forceWifiUsage(true);
    var uri = Uri.parse("http://192.168.4.1/getchipid");
    var client = http.Client();
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      chipId.value = response.body;
      selectedDevice.value = boxDevices.firstWhereOrNull(
              (e) => e.box!.chipId.toString() == chipId.value) ??
          BoxWithDevices();
    }
  }

  Future<void> getNodemcuApList() async {
    apScanning.value = true;
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

  void reviseConnModel() {
    connModel.value.apSsid = "${connModel.value.apSsid}_${chipId.value}";
    connModel.value.wifiSsid = wifiSSID.value;
    connModel.value.wifiPass = wifiPASS.value;
    connModel.value.mqttClientId = "AA${chipId.value}";
  }

  Future<void> sendDeviceSetting() async {
    uploading.value = true;
    var uri = Uri.parse("http://192.168.4.1/devicesettings");
    var client = http.Client();
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json',
      },
      body: selectedDevice.value.toJson(),
    );
    if (response.statusCode == 200) {
      if (response.body == "true") {
        sendConnectionSettings();
      } else {
        uploading.value = false;
      }
    }
  }

  Future<void> sendConnectionSettings() async {
    var uri = Uri.parse("http://192.168.4.1/connectionsettings");
    var client = http.Client();
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json',
      },
      body: connModel.toJson(),
    );
    uploading.value = true;
    await WiFiForIoTPlugin.forceWifiUsage(false);
  }
}
