import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiController extends GetxController {
  var isConnected = false.obs;
  var currentSSID = ''.obs;
  var routerIP = ''.obs;
  var timer = Timer(Duration(), () {}).obs;

  @override
  void onInit() {
    super.onInit();

    timer.value = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (currentSSID.isEmpty) {
        isConnected.value = false;
        await getSSID();
      }
    });
  }

  Future<void> getSSID() async {
    try {
      currentSSID.value = await WiFiForIoTPlugin.getSSID() ?? "";
      if (currentSSID.value.isNotEmpty) {
        isConnected.value = true;
        await getRouterIP();
      }
    } catch (e) {
      return;
    }
  }

  Future<void> getRouterIP() async {
    MethodChannel channel = MethodChannel('com.example.wifi');
    try {
      final String? ip = await channel.invokeMethod('getRouterIP');
      routerIP.value = ip ?? 'Unknown IP';
    } on PlatformException catch (e) {
      routerIP.value = 'Failed to get IP: ${e.message}';
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
