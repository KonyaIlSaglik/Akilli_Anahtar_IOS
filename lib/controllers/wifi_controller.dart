import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WifiController extends GetxController {
  var isConnected = false.obs;
  var currentSSID = ''.obs;
  var routerIP = ''.obs;
  var timer = Timer(Duration(), () {}).obs;

  @override
  void onInit() async {
    super.onInit();
    await getSSID();

    timer.value = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!isConnected.value) {
        await getSSID();
      }
    });
  }

  Future<void> getSSID() async {
    try {
      var result = await WiFiForIoTPlugin.getSSID() ?? "";
      print(result);
      currentSSID.value = result == "<unknown ssid>" ? "" : result;
      if (currentSSID.value.isNotEmpty) {
        isConnected.value = true;
        //await getRouterIP();
      } else {
        isConnected.value = false;
      }
    } catch (e) {
      return;
    }
  }

  Future<void> getRouterIP() async {
    var result = await WiFiForIoTPlugin.getIP();
    print(result);
    MethodChannel channel = MethodChannel('com.example.wifi');
    try {
      final String? ip = await channel.invokeMethod('getRouterIP');
      routerIP.value = ip ?? 'Unknown IP';
      print(routerIP.value);
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
