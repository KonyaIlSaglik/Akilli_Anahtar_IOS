import 'package:akilli_anahtar/controllers/install/nodemcu_controller.dart';
import 'package:akilli_anahtar/controllers/install/wifi_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

class WifiPageViewModel {
  static PageViewModel get(context) {
    final WifiController wifiController = Get.put(WifiController());
    final NodemcuController nodemcuController = Get.find();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return PageViewModel(
      title: "KURULUM",
      body:
          "Telefonunuzun Wifi Ayarlarına giderek AKILLI ANAHTAR cihazına bağlantı kurunuz.",
      image: Center(
        child: Icon(
          wifiController.isConnected.value ? Icons.wifi : Icons.wifi_off,
          size: 100.0,
          color: wifiController.isConnected.value ? Colors.blue : Colors.grey,
        ),
      ),
      footer: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: wifiController.isConnected.value &&
                !nodemcuController.apScanning.value
            ? Column(
                children: [
                  Center(
                    child: Icon(
                      Icons.done,
                      color: Colors.green,
                      size: 50,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Text(
                    "Bağlısınız. Sonraki adıma geçebilirsiniz",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  CircularProgressIndicator(
                    color: goldColor,
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Text("Cihaza bağlanma bekleniyor...")
                ],
              ),
      ),
      decoration: PageDecoration(
        footerFlex: 30,
        bodyFlex: 30,
        imageFlex: 40,
        pageColor: Colors.white,
        imagePadding: EdgeInsets.all(24),
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 18),
      ),
    );
  }
}
