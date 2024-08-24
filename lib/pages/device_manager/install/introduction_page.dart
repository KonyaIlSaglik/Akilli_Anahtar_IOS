import 'package:akilli_anahtar/controllers/nodemcu_controller.dart';
import 'package:akilli_anahtar/controllers/wifi_controller.dart';
import 'package:akilli_anahtar/pages/device_manager/install/c_nodemcu_page_view_model.dart';
import 'package:akilli_anahtar/pages/device_manager/install/a_start_page_view_model.dart';
import 'package:akilli_anahtar/pages/device_manager/install/d_online_page_view_model.dart';
import 'package:akilli_anahtar/pages/device_manager/install/b_wifi_page_view_model.dart';
import 'package:akilli_anahtar/pages/home/home_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:wifi_iot/wifi_iot.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final WifiController _wifiController = Get.put(WifiController());
  final NodemcuController _nodemcuController = Get.put(NodemcuController());
  final _introKey = GlobalKey<IntroductionScreenState>();
  var chipId = 0;
  int page = 0;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return IntroductionScreen(
          key: _introKey,
          showBackButton: page != 0,
          back: Text(
            "Geri",
            style: TextStyle(
              color: goldColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          controlsPadding: EdgeInsets.only(top: 50),
          showNextButton: page == 0 ||
              (page == 1 && _wifiController.isConnected.value) ||
              (page == 2 && _nodemcuController.infoModel.value.haveDevices),
          next: Text(
            page == 0 ? "Başla" : "Sonraki",
            style: TextStyle(
              color: goldColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          showSkipButton: page == 0,
          skip: Text(
            page == 0 ? "Çıkış" : "Geç",
            style: TextStyle(
              color: goldColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          done: const Text(
            "Tamamlandı",
            style: TextStyle(
              color: goldColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          onSkip: () {
            if (page == 0) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Çıkış"),
                    content: Text("Kurulumdan çıkış yapmak istiyor musunuz?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Geri dön",
                          style: TextStyle(color: goldColor),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          WiFiForIoTPlugin.forceWifiUsage(false);
                          Get.to(HomePage());
                        },
                        child: Text(
                          "Çıkış",
                          style: TextStyle(color: goldColor),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else {
              _introKey.currentState?.skipToEnd();
            }
          },
          onDone: () {
            _nodemcuController.disconnect();
            WiFiForIoTPlugin.forceWifiUsage(false);
            Get.to(HomePage());
          },
          onChange: (value) async {
            setState(() {
              page = value;
            });
            if (value == 2) {
              await _nodemcuController.getNodemcuInfo();
              await _nodemcuController.sendDeviceSetting();
            }
            if (value == 3) {
              await _nodemcuController.getNodemcuApList();
            }
          },
          pages: [
            StartPageViewModel.get(context),
            WifiPageViewModel.get(context),
            NodemcuPageViewModel.get(context),
            OnlinePageViewModel.get(context),
          ],
        );
      },
    );
  }
}
