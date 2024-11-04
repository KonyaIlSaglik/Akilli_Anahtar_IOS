import 'dart:async';
import 'dart:ui';

import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';

class BackgroundController extends GetxController {
  var serviceIsNull = true.obs;
  FlutterBackgroundService service = FlutterBackgroundService();

  Future<void> initializeService() async {
    WidgetsFlutterBinding.ensureInitialized();

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStartService,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: onStartService,
        isForegroundMode: false,
        autoStartOnBoot: true,
      ),
    );
    serviceIsNull.value = false;
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStartService(ServiceInstance service) async {
  service.on("start").listen((event) {});
  MqttController mqttController = Get.put(MqttController());
  await mqttController.initClient();
  await mqttController.connect();
  mqttController.subscribeToTopic("BBBB");
  mqttController.onMessage(
    (topic, message) {
      if (topic == "BBBB") {
        print("BBBB den gelen mesaj: $message");
      }
    },
  );
  Timer.periodic(const Duration(seconds: 10), (timer) {
    print("service is successfully running ${DateTime.now().second}");
  });
}
