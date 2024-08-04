// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:akilli_anahtar/widgets/custom_button.dart';
import 'package:akilli_anahtar/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

import 'package:akilli_anahtar/utils/constants.dart';

class NodeMcuConnectionPage extends StatefulWidget {
  final void Function(bool value)? isConnected;

  NodeMcuConnectionPage({
    Key? key,
    this.isConnected,
  }) : super(key: key);

  @override
  State<NodeMcuConnectionPage> createState() => _NodeMcuConnectionPageState();
}

class _NodeMcuConnectionPageState extends State<NodeMcuConnectionPage> {
  bool wifiEnable = false;
  bool wifiEnableBefore = false;
  bool isConnected = false;
  bool scanning = false;
  String connectedSSID = "";
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  late Timer timer;
  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  void initState() {
    super.initState();
    WiFiForIoTPlugin.forceWifiUsage(true);
    WiFiForIoTPlugin.isEnabled().then((value) {
      WiFiForIoTPlugin.isConnected().then((value) {
        setState(() {
          isConnected = value;
          widget.isConnected!(value);
        });
        if (isConnected) {
          if (timer.isActive) {
            timer.cancel();
          }
          WiFiForIoTPlugin.getSSID().then((value) {
            if (value!.isNotEmpty) {
              setState(() {
                connectedSSID = value;
              });
            }
          });
        }
      });
      setState(() {
        wifiEnable = value;
        wifiEnableBefore = wifiEnable;
        if (wifiEnable) {
          startScan();
        }
      });
    });
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      WiFiForIoTPlugin.isEnabled().then((value) {
        setState(() {
          wifiEnable = value;
          if (wifiEnableBefore == !wifiEnable) {
            setState(() {
              wifiEnableBefore = wifiEnable;
            });
            if (!wifiEnable) {
              setState(() {
                print("Wifi kapandı");
                scanning = false;
                isConnected = false;
                accessPoints = List.empty();
              });
            } else {
              print("Wifi açıldı");
              if (accessPoints.isEmpty && !scanning) {
                startScan();
              }
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
    var passController = TextEditingController();
    final passwordFocus = FocusNode();
    var selectedSSID = "";
    return SizedBox(
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
              subtitle: Text(
                wifiEnable ? "Açık" : "Kapalı",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
              trailing: ElevatedButton(
                child: Text("Tara"),
                onPressed: () {
                  if (wifiEnable) {
                    startScan();
                  }
                },
              ),
            ),
            Divider(color: Colors.white),
            Expanded(
              child: scanning
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
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
                              const color = Colors.white;
                              final signalIcon = accessPoints[i].level >= -80
                                  ? Icons.wifi
                                  : Icons.wifi_2_bar_outlined;
                              return ListTile(
                                visualDensity: VisualDensity.compact,
                                leading: Icon(signalIcon, color: color),
                                title: Text(
                                  accessPoints[i].ssid,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: color),
                                ),
                                subtitle: connectedSSID == accessPoints[i].ssid
                                    ? Text(
                                        "Bağlandı",
                                        style: TextStyle(
                                          color: color,
                                        ),
                                      )
                                    : null,
                                trailing: Icon(
                                  Icons.lock_outlined,
                                  color: Colors.white,
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedSSID = accessPoints[i].ssid;
                                  });
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: goldColor,
                                      title: Text(selectedSSID),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CustomTextField(
                                            controller: passController,
                                            icon: Icon(Icons.lock),
                                            focusNode: passwordFocus,
                                            hintText: "Şifre",
                                            isPassword: true,
                                          ),
                                          CustomButton(
                                            title: "BAĞLAN",
                                            onPressed: () {
                                              WiFiForIoTPlugin.isEnabled()
                                                  .then((value) {
                                                if (value) {
                                                  WiFiForIoTPlugin
                                                          .findAndConnect(
                                                              selectedSSID,
                                                              password:
                                                                  passController
                                                                      .text)
                                                      .then((value) {
                                                    setState(() {
                                                      isConnected = value;
                                                      if (isConnected) {
                                                        if (timer.isActive) {
                                                          timer.cancel();
                                                        }
                                                        reOrder();
                                                        connectedSSID =
                                                            selectedSSID;
                                                      }
                                                      widget
                                                          .isConnected!(value);
                                                    });
                                                    Navigator.pop(context);
                                                  });
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  startScan() async {
    final canStartScan =
        await WiFiScan.instance.canStartScan(askPermissions: true);
    if (canStartScan == CanStartScan.yes) {
      final isScanning = await WiFiScan.instance.startScan();
      setState(() {
        print("tarama başladı");
        scanning = isScanning;
      });
      if (scanning) {
        final canGetScannedResults =
            await WiFiScan.instance.canGetScannedResults(askPermissions: true);
        if (canGetScannedResults == CanGetScannedResults.yes) {
          subscription =
              WiFiScan.instance.onScannedResultsAvailable.listen((results) {
            print(results.length);
            setState(() {
              scanning = false;
              accessPoints = results;
            });
            reOrder();
          });
        }
      }
    }
  }

  reOrder() {
    if (isConnected && connectedSSID.isNotEmpty) {
      var connectedAP =
          accessPoints.where((e) => e.ssid == connectedSSID).first;
      var temp = List<WiFiAccessPoint>.from(accessPoints);
      if (temp.indexOf(connectedAP) > 0) {
        temp.removeAt(temp.indexOf(connectedAP));
        temp.insert(0, connectedAP);
        setState(() {
          accessPoints = temp;
        });
      }
    }
  }
}
