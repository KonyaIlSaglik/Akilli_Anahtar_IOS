import 'package:akilli_anahtar/controllers/nodemcu_controller.dart';
import 'package:akilli_anahtar/controllers/wifi_controller.dart';
import 'package:akilli_anahtar/pages/device_manager/install/a_start_page_view_model.dart';
import 'package:akilli_anahtar/pages/device_manager/install/b_wifi_page_view_model.dart';
import 'package:akilli_anahtar/pages/device_manager/install/d_online_page_view_model.dart';
import 'package:akilli_anahtar/pages/home/home_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  var chipId = 0;
  int page = 0;

  final _introKey = GlobalKey<IntroductionScreenState>();
  final NodemcuController _nodemcuController = Get.put(NodemcuController());
  final WifiController _wifiController = Get.put(WifiController());

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () async {
        await _nodemcuController.getDeviceList();
        await _nodemcuController.getConnModel();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Center(
          child: _nodemcuController.uploading.value
              ? Scaffold(
                  appBar: AppBar(
                    toolbarHeight: 0,
                  ),
                  body: Center(
                    child: CircularProgressIndicator(
                      color: goldColor,
                    ),
                  ),
                )
              : IntroductionScreen(
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
                  showNextButton: (page == 0 &&
                          _nodemcuController.downloaded.value &&
                          !_nodemcuController.boxDevicesIsEmpty.value) ||
                      (page == 1 &&
                          _wifiController.isConnected.value &&
                          _nodemcuController.boxDevices.isNotEmpty),
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
                            content: Text(
                                "Kurulumdan çıkış yapmak istiyor musunuz?"),
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
                                  Get.to(() => HomePage());
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
                  onDone: () async {
                    _nodemcuController.reviseConnModel();
                    await _nodemcuController.sendDeviceSetting();
                    Get.to(() => HomePage());
                  },
                  onChange: (value) async {
                    setState(() {
                      page = value;
                    });
                    if (page == 2) {
                      await _nodemcuController.getChipId();
                      if (_nodemcuController.selectedDevice.value.box != null) {
                        await _nodemcuController.getNodemcuApList();
                      }
                    }
                  },
                  pages: [
                    StartPageViewModel.get(context),
                    WifiPageViewModel.get(context),
                    // NodemcuPageViewModel.get(context),
                    OnlinePageViewModel.get(context),
                  ],
                ),
        );
      },
    );
  }
}
