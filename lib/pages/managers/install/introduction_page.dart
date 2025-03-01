import 'package:akilli_anahtar/controllers/install/nodemcu_controller.dart';
import 'package:akilli_anahtar/pages/managers/install/b_wifi_page_view_model.dart';
import 'package:akilli_anahtar/pages/managers/install/d_online_page_view_model.dart';
import 'package:akilli_anahtar/pages/new_home/layout.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  var chipId = 0;
  int page = 0;

  final _introKey = GlobalKey<IntroductionScreenState>();
  final NodemcuController _nodemcuController = Get.put(NodemcuController());

  @override
  void initState() {
    super.initState();
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
                  showNextButton: (page == 0),
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
                                  Get.back();
                                  Get.back();
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
                  onChange: (value) async {
                    setState(() {
                      page = value;
                    });
                    if (page == 1) {
                      await _nodemcuController.getNodemcuApList();
                    }
                  },
                  onDone: () async {
                    await _nodemcuController.sendConnectionSettings();
                    Get.to(() => Layout());
                  },
                  pages: [
                    WifiPageViewModel.get(context),
                    OnlinePageViewModel.get(context),
                  ],
                ),
        );
      },
    );
  }
}
