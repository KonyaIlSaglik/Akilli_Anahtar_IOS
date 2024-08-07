// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:akilli_anahtar/models/box_with_devices.dart';
import 'package:akilli_anahtar/services/api/device_service.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:akilli_anahtar/utils/constants.dart';

class NodeMcuConnectionPage extends StatefulWidget {
  final void Function(bool value, int chipId)? isConnected;

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
  var selectedSSID = "";
  bool isConnected = false;
  bool connecting = false;
  String status = "";
  bool scanning = false;
  String connectedSSID = "";
  int chipId = 0;

  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  Timer timer = Timer(Duration(milliseconds: 1), () {});
  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  void initState() {
    super.initState();
    timer.cancel();
    init();
  }

  init() async {
    var enabled = await WiFiForIoTPlugin.isEnabled();
    setState(() {
      wifiEnable = enabled;
      wifiEnableBefore = wifiEnable;
    });
    if (enabled) {
      var connected = await WiFiForIoTPlugin.isConnected();
      if (connected != null) {
        await WiFiForIoTPlugin.disconnect();
      }
      startScan();
    }
    startTimer();
  }

  startTimer() {
    if (!timer.isActive) {
      setState(() {
        print("timer started");
        timer = Timer.periodic(Duration(seconds: 10), (timer) async {
          var enabled = await WiFiForIoTPlugin.isEnabled();
          setState(() {
            wifiEnable = enabled;
          });
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
              if (accessPoints.isEmpty && !scanning) {
                print("Wifi açıldı");
                startScan();
              }
            }
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
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
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                wifiEnable ? "Açık" : "Kapalı",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      if (wifiEnable) {
                        startScan();
                      }
                    },
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      //
                    },
                    icon: Icon(
                      Icons.qr_code,
                      color: Colors.white,
                    ),
                  ),
                ],
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
                          child: Text(
                            "Wifi bulunamadı.",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : connecting
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
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
                                  var ap = accessPoints[i];
                                  const color = Colors.white;
                                  final signalIcon = ap.level >= -80
                                      ? Icons.wifi
                                      : Icons.wifi_2_bar_outlined;
                                  return ListTile(
                                    visualDensity: VisualDensity.compact,
                                    leading: Icon(signalIcon, color: color),
                                    title: Text(
                                      ap.ssid,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: color),
                                    ),
                                    subtitle: connectedSSID == ap.ssid
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
                                    onTap: () async {
                                      setState(() {
                                        connecting = true;
                                        selectedSSID = ap.ssid;
                                        status = "$selectedSSID bağlanılıyor";
                                      });
                                      var resultConnect =
                                          await WiFiForIoTPlugin.findAndConnect(
                                              connectedSSID,
                                              password: "AA123456");
                                      if (resultConnect) {
                                        print(resultConnect
                                            ? "bağlandı..."
                                            : "hata");
                                        await Future.delayed(
                                          Duration(seconds: 5),
                                        );
                                        setState(() {
                                          status = "Kutu bilgileri alınıyor";
                                        });
                                        await getChipId();
                                      }
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

  Future<void> getChipId() async {
    var uri = Uri.parse("http://192.168.4.1/_ac");
    var client = http.Client();
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var doc = parse(response.body);
      var table = doc.body!.getElementsByClassName("info")[0];
      var rows = table.getElementsByTagName("tr");
      for (var row in rows) {
        if (row.getElementsByTagName("td")[0].innerHtml == "Chip ID") {
          var id =
              int.tryParse(row.getElementsByTagName("td")[1].innerHtml) ?? 0;
          setState(() {
            chipId = id;
          });
        }
      }
    }
    if (chipId > 0) {
      setState(() {
        isConnected = true;
        if (timer.isActive) {
          timer.cancel();
        }
        reOrder();
        connectedSSID = selectedSSID;
        widget.isConnected!(true, chipId);
        status = "Sistemden veriler alınıyor";
      });
      var devices = await DeviceService.getBoxDevices(chipId);
      if (devices != null) {
        setState(() {
          status = "Veriler Cihaza yükleniyor...";
        });
        await sendDeviceSetting(devices);
      } else {
        CherryToast.error(
          toastPosition: Position.top,
          title: Text("Sistemde kutuya ait bilgiler bulunamadı."),
        ).show(context);
      }
      setState(() {
        connecting = false;
      });
      CherryToast.success(
        toastPosition: Position.top,
        title: Text("Cihaz bilgileri alındı. Sonraki adıma geçebilirsiniz."),
      ).show(context);
    } else {
      CherryToast.error(
        toastPosition: Position.top,
        title: Text("Cihaz bilgileri alınamadı. Yeniden bağlanmayı deneyin."),
      ).show(context);
      await WiFiForIoTPlugin.disconnect();
      startTimer();
    }
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
            var list = results.where((a) => a.ssid.isNotEmpty).toList();
            list.sort(
              (a, b) => a.ssid.compareTo(b.ssid),
            );
            setState(() {
              scanning = false;
              accessPoints = list;
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

  Future<bool> sendDeviceSetting(BoxWithDevices devices) async {
    var uri = Uri.parse("http://192.168.4.1/devicesettings");
    var client = http.Client();
    client
        .post(
      uri,
      headers: {
        'content-type': 'application/json',
      },
      body: devices.toJson(),
    )
        .then((response) {
      if (response.statusCode == 200) {
        CherryToast.success(
          toastPosition: Position.bottom,
          title: Text(response.body),
        ).show(context);
        return true;
      } else {
        CherryToast.error(
          toastPosition: Position.bottom,
          title: Text(response.body),
        ).show(context);
      }
    });
    return false;
  }
}
