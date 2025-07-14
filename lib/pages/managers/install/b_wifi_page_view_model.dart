import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class WifiPageViewModel {
  static PageViewModel get(context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return PageViewModel(
      title: "KURULUM",
      body: "Akıllı Anahtar cihazınızın açık olup olmadığını kontrol ediniz.",
      image: Center(
        child: Icon(
          Icons.wifi,
          size: width * 0.75,
          color: Colors.blue,
        ),
      ),
      footer: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: Column(
          children: [
            SizedBox(
              height: height * 0.01,
            ),
            Text("Cihaz açık ise kuruluma başlayabilirsiniz")
          ],
        ),
      ),
      decoration: PageDecoration(
        footerFlex: 10,
        bodyFlex: 25,
        imageFlex: 50,
        pageColor: Colors.white,
        //imagePadding: EdgeInsets.all(24),
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 18),
      ),
    );
  }
}
