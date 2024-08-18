import 'package:akilli_anahtar/controllers/wifi_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

class WifiPageViewModel {
  static PageViewModel get(context) {
    final WifiController wifiController = Get.put(WifiController());
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return PageViewModel(
      title: "HOŞGELİDİNİZ",
      body:
          "Telefonunuzun Wifi Ayarlarına giderek AKILLI ANAHTAR cihazına bağlantı kurunuz. Bağlantı sonrası bir sonraki adıma geçebilirsiniz.",
      image: Center(
        child: Icon(
          wifiController.isConnected.value ? Icons.wifi : Icons.wifi_off,
          size: 100.0,
          color: wifiController.isConnected.value ? Colors.blue : Colors.grey,
        ),
      ),
      footer: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: wifiController.isConnected.value
            ? Column(
                children: [
                  Icon(
                    Icons.done,
                    color: Colors.green,
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Text("Bağlısınız. Sonraki adıma geçebilirsiniz.")
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
                  Text("Cihaza bağlanma bekleniyor.")
                ],
              ),
      ),
      decoration: PageDecoration(
        footerFlex: 10,
        bodyFlex: 40,
        imageFlex: 50,
        pageColor: Colors.white,
        imagePadding: EdgeInsets.all(24),
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 18),
      ),
    );
  }
}
