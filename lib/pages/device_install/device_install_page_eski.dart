import 'dart:async';

import 'package:akilli_anahtar/pages/device_install/wifi_list_item.dart';
import 'package:akilli_anahtar/pages/home/home_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:wifi_iot/wifi_iot.dart';
//import 'package:http/http.dart' as http;
import 'package:wifi_scan/wifi_scan.dart';

class DeviceInstallPageEski extends StatefulWidget {
  const DeviceInstallPageEski({Key? key}) : super(key: key);

  @override
  State<DeviceInstallPageEski> createState() => _DeviceInstallPageEskiState();
}

class _DeviceInstallPageEskiState extends State<DeviceInstallPageEski> {
  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  final wifiController = ValueNotifier<bool>(false);
  int pageIndex = 0;
  bool wifiEnable = false;
  bool mobilEnable = false;
  bool firtPageOk = false;
  bool isConnected = false;
  bool scanning = true;
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  @override
  void initState() {
    super.initState();
    StreamSubscription<List<ConnectivityResult>> subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      setState(() {
        mobilEnable = result.contains(ConnectivityResult.mobile);
        firtPageOk = wifiEnable && !mobilEnable;
      });
    });
  }

  Widget _buildInfo(String label, dynamic value) => Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(child: Text(value.toString()))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return IntroductionScreen(
      onChange: (value) {
        setState(() {
          pageIndex = value;
        });
      },
      pages: [
        PageViewModel(
          decoration: PageDecoration(
            titlePadding: EdgeInsets.symmetric(vertical: height * 0.05),
            footerFlex: 10,
            bodyFlex: 70,
            imageFlex: 20,
          ),
          image: Icon(Icons.wifi),
          title:
              "AKILLI ANAHTAR a bağlanilmek ve konfigürasyonu tamamlayabilmek için mobil veriyi kapatıp wifi bağlantısını açarak sayfayı yenileyin.",
          bodyWidget: Column(
            children: [
              _buildInfo("Kablosuz ağ", wifiEnable ? "Açık" : "Kapalı"),
              _buildInfo("Mobil Ağ", mobilEnable ? "Açık" : "Kapalı"),
              SizedBox(
                height: height * 0.25,
              ),
              Center(
                child: Icon(
                  wifiEnable && !mobilEnable ? Icons.done_all : Icons.close,
                  size: 50,
                  color:
                      wifiEnable && !mobilEnable ? Colors.green : Colors.grey,
                ),
              )
            ],
          ),
        ),
        PageViewModel(
          //image: Icon(Icons.done_outlined, size: 50),
          decoration: PageDecoration(
            titlePadding: EdgeInsets.symmetric(vertical: 25),
            footerFlex: 10,
            bodyFlex: 100,
          ),
          // footer: Center(
          //     child:
          //         Text("Listeden Akıllı Anahtar cihazınızı seçip bağlanın.")),
          image: isConnected ? Icon(Icons.done) : null,
          title: "Cihazınızı Bağlayın.",
          bodyWidget: Card(
            color: goldColor,
            elevation: 5,
            child: Column(
              children: [
                ListTile(
                    title: Text("Kablosuz"),
                    trailing: AdvancedSwitch(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      inactiveChild: Text("OFF"),
                      activeChild: Text("ON"),
                      width: 70,
                      controller: wifiController,
                      activeColor: Colors.blue,
                      inactiveColor: Colors.white60,
                    )),
                Center(
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
                              height: MediaQuery.of(context).size.height * 0.70,
                              child: ListView.separated(
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(),
                                itemCount: accessPoints.length,
                                itemBuilder: ((context, i) {
                                  return WifiListItem(
                                      accessPoint: accessPoints[i]);
                                  // return Padding(
                                  //   padding: const EdgeInsets.symmetric(horizontal: 10),
                                  //   child: ListTile(
                                  //     leading: Icon(Icons.wifi),
                                  //     title: Text(accessPoints[i].ssid),
                                  //     subtitle: Text(accessPoints[i].capabilities),
                                  //     trailing: Icon(Icons.chevron_right_outlined),
                                  //   ),
                                  // );
                                }),
                              ),
                            ),
                ),
              ],
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
      controlsPadding: EdgeInsets.only(top: 50),
      showNextButton: pageIndex == 0 && !firtPageOk ? false : true,
      next: Text("Sonraki"),
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
    );
  }
}



/*

Scaffold(
      appBar: AppBar(
        backgroundColor: goldColor,
        actions: [
          IconButton(
            onPressed: () {
              startScan();
            },
            icon: Icon(
              Icons.refresh_outlined,
            ),
          )
        ],
      ),
      body: scanning
          ? Center(
              child: CircularProgressIndicator(),
            )
          : accessPoints.isEmpty
              ? Center(
                  child: Text("Wifi bulunamadı."),
                )
              : ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemCount: accessPoints.length,
                  itemBuilder: ((context, i) {
                    return AccessPointTile(accessPoint: accessPoints[i]);
                    // return Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 10),
                    //   child: ListTile(
                    //     leading: Icon(Icons.wifi),
                    //     title: Text(accessPoints[i].ssid),
                    //     subtitle: Text(accessPoints[i].capabilities),
                    //     trailing: Icon(Icons.chevron_right_outlined),
                    //   ),
                    // );
                  }),
                ),
    );

*/
