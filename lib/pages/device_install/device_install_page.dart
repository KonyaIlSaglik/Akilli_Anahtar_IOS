import 'dart:async';

import 'package:akilli_anahtar/pages/device_install/wifi_list_item.dart';
import 'package:akilli_anahtar/pages/home/home_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

class DeviceInstallPage extends StatefulWidget {
  const DeviceInstallPage({Key? key}) : super(key: key);

  @override
  State<DeviceInstallPage> createState() => _DeviceInstallPageState();
}

class _DeviceInstallPageState extends State<DeviceInstallPage> {
  bool wifiEnable = false;
  bool isConnected = false;
  bool scanning = false;
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  @override
  void initState() {
    super.initState();
    WiFiForIoTPlugin.isEnabled().then((value) {
      setState(() {
        wifiEnable = value;
        if (wifiEnable) {
          startScan();
        }
      });
    });
    Timer.periodic(Duration(seconds: 1), (timer) {
      WiFiForIoTPlugin.isEnabled().then((value) {
        setState(() {
          wifiEnable = value;
          if (!wifiEnable) {
            setState(() {
              scanning = false;
              accessPoints.clear();
            });
          } else {
            if (accessPoints.isEmpty) {
              setState(() {
                scanning = true;
              });
              startScan();
            }
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return IntroductionScreen(
      controlsPadding: EdgeInsets.only(top: 50),
      showNextButton: isConnected,
      next: ElevatedButton(
        child: Text("Sonraki"),
        onPressed: () {
          //
        },
      ),
      //showBackButton: true,
      //back: Text("Önceki"),
      showSkipButton: true,
      skip: Text("Geç"),
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
          bodyWidget: SizedBox(
            width: width * 0.80,
            height: height * 0.60,
            child: Card(
              color: goldColor,
              elevation: 5,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Kablosuz",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Text(
                      wifiEnable ? "Açık" : "Kapalı",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Divider(color: Colors.white),
                  Expanded(
                    child: scanning
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : accessPoints.isEmpty
                            ? Center(
                                child: Text("Wifi bulunamadı."),
                              )
                            : SizedBox(
                                width: MediaQuery.of(context).size.width * 0.90,
                                height:
                                    MediaQuery.of(context).size.height * 0.70,
                                child: ListView.separated(
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const Divider(),
                                  itemCount: accessPoints.length,
                                  itemBuilder: ((context, i) {
                                    return WifiListItem(
                                      accessPoint: accessPoints[i],
                                      onPressed: () {
                                        WiFiForIoTPlugin.isEnabled()
                                            .then((value) {
                                          if (value) {
                                            WiFiForIoTPlugin.connect(
                                                    accessPoints[i].ssid,
                                                    password: "AA123456")
                                                .then((value) {
                                              setState(() {
                                                isConnected = value;
                                              });
                                              Navigator.pop(context);
                                            });
                                          }
                                        });
                                      },
                                    );
                                  }),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
        PageViewModel(
          title: "Title of introduction page",
          body: "Welcome to the app! This is a description of how it works.",
          image: const Center(
            child: Icon(Icons.waving_hand, size: 50.0),
          ),
        ),
      ],
    );
  }

  startScan() {
    WiFiScan.instance.startScan().then((isScanned) {
      if (isScanned) {
        WiFiScan.instance.getScannedResults().then((results) {
          setState(() {
            accessPoints = results;
            scanning = false;
          });
        });
      }
    });
  }

  girisButon(double height) {
    return ButtonTheme(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: OutlinedButton(
          onPressed: () async {
            //
          },
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            minimumSize: Size(double.infinity, height * 0.075),
          ),
          child: Text(
            "Sonraki",
            style: TextStyle(
              color: Colors.black,
              fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
