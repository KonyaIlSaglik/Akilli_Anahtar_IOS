import 'package:get/get.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiController extends GetxController {
  var isScanning = false.obs;
  var scanError = ''.obs;
  var isConnected = false.obs;
  var currentSSID = ''.obs;
  var availableNetworks = <WiFiAccessPoint>[].obs;

  @override
  void onInit() {
    super.onInit();
    checkConnectionStatus();
  }

  Future<void> checkConnectionStatus() async {
    isConnected.value = await WiFiForIoTPlugin.isConnected();
    if (isConnected.value) {
      currentSSID.value = await WiFiForIoTPlugin.getSSID() ?? '';
    }
  }

  Future<void> connectToNetwork(String ssid, String password) async {
    bool success = await WiFiForIoTPlugin.connect(ssid,
        password: password, security: NetworkSecurity.WPA);
    isConnected.value = success;
    if (success) {
      currentSSID.value = ssid;
    }
  }

  Future<void> disconnectFromNetwork() async {
    bool success = await WiFiForIoTPlugin.disconnect();
    isConnected.value = !success;
    if (!success) {
      currentSSID.value = '';
    }
  }
}
