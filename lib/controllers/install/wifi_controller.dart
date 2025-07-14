import 'dart:async';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WifiController extends GetxController {
  var isConnected = false.obs;
  var currentIp = ''.obs;
  var timer = Timer(Duration(), () {}).obs;
  var info = NetworkInfo();

  @override
  void onInit() async {
    super.onInit();
    await getIP();

    timer.value = Timer.periodic(Duration(seconds: 1), (timer) async {
      await getIP();
    });
  }

  Future<void> getIP() async {
    try {
      var result = await WiFiForIoTPlugin.getIP() ?? "";
      result = result.toLowerCase().contains("unknown") ? "" : result;
      result = result.contains("192.168.4.") ? result : "";
      currentIp.value = result;
      if (currentIp.value.isNotEmpty) {
        isConnected.value = true;
      } else {
        isConnected.value = false;
      }
    } catch (e) {
      isConnected.value = false;
      return;
    }
  }

  Future<String> getBSSID() async {
    return await info.getWifiBSSID() ?? "00:00:00:00:00:00";
  }

  Future<String> getSSID() async {
    return (await info.getWifiName())?.replaceAll("\"", "") ?? "";
  }

  Future<void> connectToNetwork(String ssid, String password) async {
    bool success = await WiFiForIoTPlugin.connect(ssid,
        password: password, security: NetworkSecurity.WPA);
    isConnected.value = success;
    if (success) {
      currentIp.value = ssid;
    }
  }

  Future<void> disconnectFromNetwork() async {
    bool success = await WiFiForIoTPlugin.disconnect();
    isConnected.value = !success;
    if (!success) {
      currentIp.value = '';
    }
  }
}
