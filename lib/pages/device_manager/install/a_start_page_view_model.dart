import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class StartPageViewModel {
  static PageViewModel get(context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return PageViewModel(
      title: "HOŞGELİDİNİZ",
      body:
          "Kurulum işlemleri için wifi ile cihaza bağlamanız gerekmektedir. Devam ettiğinizde cihazdaki tüm veriler sıfırlanarak yeniden yüklenecektir. Kurulum sonrası cihazı bir internete bağlayabilir ya da ofline kullanım ile devam edebilirsiniz.\nNot: Offline kullanım için Akıllı Anahtar cihazına wifi ile bağlı olmanız gerekmektedir.",
      image: Center(
        child: Image.asset(
          "assets/anahtar.png",
        ),
      ),
      footer: Column(
        children: [
          Icon(
            Icons.done,
            color: Colors.green,
            size: 50,
          ),
          SizedBox(
            height: height * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Devam etmek için ",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                "'Başla'",
                style: TextStyle(
                  color: goldColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                " butonuna basınız.",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
      decoration: PageDecoration(
        footerFlex: 20,
        bodyFlex: 40,
        imageFlex: 40,
        pageColor: Colors.white,
        imagePadding: EdgeInsets.symmetric(horizontal: width * 0.10),
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 18),
      ),
    );
  }
}
