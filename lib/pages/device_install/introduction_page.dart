import 'package:akilli_anahtar/pages/device_install/nodemcu_connection_page.dart';
import 'package:akilli_anahtar/pages/device_install/user_devices_page.dart';
import 'package:akilli_anahtar/pages/device_install/wifi_connection_page.dart';
import 'package:akilli_anahtar/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  var apConnected = false;
  @override
  Widget build(BuildContext context) {
    //var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return IntroductionScreen(
      canProgress: (page) {
        if (page == 0 && !apConnected) {
          return false;
        }
        return true;
      },
      showBackButton: true,
      back: Text("Geri"),
      controlsPadding: EdgeInsets.only(top: 50),
      showNextButton: apConnected,
      next: Text("Sonraki"),
      //showSkipButton: true,
      //skip: Text("Geç"),
      done: const Text("Tamamlandı"),
      onDone: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      },
      pages: [
        PageViewModel(
          decoration: PageDecoration(
            titlePadding: EdgeInsets.symmetric(vertical: height * 0.05),
            footerFlex: 10,
            bodyFlex: 70,
            imageFlex: 30,
          ),
          title: "",
          bodyWidget: NodeMcuConnectionPage(
            isConnected: (isConnected) {
              connected(isConnected);
            },
          ),
        ),
        PageViewModel(
          decoration: PageDecoration(
            titlePadding: EdgeInsets.symmetric(vertical: height * 0.05),
            footerFlex: 10,
            bodyFlex: 70,
            imageFlex: 30,
          ),
          title: "",
          bodyWidget: WifiConnectionPage(),
        ),
        PageViewModel(
          decoration: PageDecoration(
            titlePadding: EdgeInsets.symmetric(vertical: height * 0.05),
            footerFlex: 10,
            bodyFlex: 70,
            imageFlex: 30,
          ),
          title: "",
          bodyWidget: UserDevicesPage(),
        ),
      ],
    );
  }

  void connected(bool value) {
    setState(() {
      apConnected = value;
    });
  }
}
