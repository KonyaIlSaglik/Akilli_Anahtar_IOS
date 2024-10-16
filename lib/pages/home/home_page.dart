import 'dart:io';

import 'package:akilli_anahtar/controllers/mqtt_controller.dart';
import 'package:akilli_anahtar/pages/home/datetime/date_view.dart';
import 'package:akilli_anahtar/pages/home/datetime/time_view.dart';
import 'package:akilli_anahtar/pages/home/index/index_page.dart';
import 'package:akilli_anahtar/pages/home/tab_page/tab_view.dart';
import 'package:akilli_anahtar/pages/home/toolbar/toolbar_view.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'drawer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MqttController _mqttController = Get.put(MqttController());

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    var info = DeviceInfoPlugin();
    String deviceId = "";
    if (Platform.isAndroid) {
      var androidInfo = await info.androidInfo;
      print("1 - ${androidInfo.device}");
      print("2 - ${androidInfo.display}");
      print("3 - ${androidInfo.host}");
      print("4 - ${androidInfo.model}");
      print("5 - ${androidInfo.product}");
      print("6 - ${androidInfo.board}");
      print("7 - ${androidInfo.bootloader}");
      print("8 - ${androidInfo.brand}");
      print("9 - ${androidInfo.fingerprint}");
      print("10 - ${androidInfo.tags}");
      print("11 - ${androidInfo.type}");
    }
    if (Platform.isIOS) {
      var iosInfo = await info.iosInfo;
      deviceId =
          iosInfo.identifierForVendor ?? "${iosInfo.name}-${iosInfo.model}";
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        exitApp(context);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: height * 0.10,
          leadingWidth: width * 0.15,
          title: SizedBox(
            height: height * 0.10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Toolbar(),
                SizedBox(
                  width: width * 0.05,
                ),
              ],
            ),
          ),
        ),
        drawer: DrawerPage(),
        body: Column(
          children: [
            SizedBox(
              height: height * 0.1,
              child: TimeView(),
            ),
            SizedBox(
              height: height * 0.06,
              child: DateView(),
            ),
            Expanded(
              child: Obx(() {
                return _mqttController.connecting.value
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : _mqttController.isConnected.value
                        ? TabView()
                        : IndexPage();
              }),
            ),
          ],
        ),
      ),
    );
  }
}
