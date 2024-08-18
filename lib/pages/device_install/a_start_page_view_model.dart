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
          "Kurulum işlemleri için wifi ile cihaza bağlamanız gerekmektedir. Bağlandıktan sonra devam ettiğinizde cihazdaki tüm veriler sıfırlanarak yeniden yüklenecektir. Daha sonra da online kullanım için cihazı bir internete bağlayabilir ya da ofline kullanım ile devam edebilirsiniz.\nNot: Uygulumayı offline kullanabilmek için Akıllı Anahtar cihazına wifi ile bağlı olmanız gerekmektedir.",
      image: Center(
        child: Image.asset(
          "assets/anahtar.png",
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Devam etmek için "),
          Text(
            "'Sonraki'",
            style: TextStyle(
              color: goldColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(" butonuna basınız."),
        ],
      ),
      decoration: PageDecoration(
        footerFlex: 10,
        bodyFlex: 50,
        imageFlex: 50,
        pageColor: Colors.white,
        imagePadding: EdgeInsets.symmetric(horizontal: width * 0.10),
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 18),
      ),
    );
  }
}
