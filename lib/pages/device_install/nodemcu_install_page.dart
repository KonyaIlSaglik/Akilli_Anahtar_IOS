import 'dart:async';
import 'dart:convert';

import 'package:akilli_anahtar/models/mqtt_connection_model.dart';
import 'package:akilli_anahtar/models/wifi_model.dart';
import 'package:akilli_anahtar/pages/home/home_page.dart';
import 'package:akilli_anahtar/services/api/device_service.dart';
import 'package:akilli_anahtar/services/api/parameter_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_button.dart';
import 'package:akilli_anahtar/widgets/custom_text_field.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class NodemcuInstallPage extends StatefulWidget {
  const NodemcuInstallPage({Key? key}) : super(key: key);

  @override
  State<NodemcuInstallPage> createState() => _NodemcuInstallPageState();
}

class _NodemcuInstallPageState extends State<NodemcuInstallPage> {
  bool isConnected = false;
  String connectionStatus = "-";
  String connectedSSID = "";
  int chipId = 0;
  bool isEntegration = false;
  String entegrationStatus = "-";
  bool wifiOk = false;

  final passwordFocus = FocusNode();
  final passwordcon = TextEditingController();
  final ssidFocus = FocusNode();
  final ssidcon = TextEditingController();
  String wifiSSID = "";
  String wifiPassword = "";
  String wifiStatus = "-";
  @override
  void initState() {
    super.initState();
    startScan();
    init();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: goldColor,
        title: Text("Akıllı Anahtar Kurulum"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              //
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.40,
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(isConnected ? Icons.done : Icons.close),
                  title: Text("Cihaz Bağlantısı"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(connectionStatus),
                      Text("Cihaz Id: $chipId"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.help_outline),
                        onPressed: () {
                          //
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right_outlined),
                        onPressed: () {
                          //
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  enabled: isConnected,
                  leading: Icon(isEntegration ? Icons.done : Icons.close),
                  title: Text("Cihaz Entegrasyonu"),
                  subtitle: Text(entegrationStatus),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.help_outline),
                        onPressed: () {
                          //
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.sync_outlined),
                        onPressed: isConnected
                            ? () async {
                                await deviceEntegration();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  enabled: isEntegration,
                  leading: Icon(wifiOk ? Icons.done : Icons.close),
                  title: Text("Online Bağlantı Ayarları"),
                  subtitle: Text("Online Bağlantı yok"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.help_outline),
                        onPressed: () {
                          //
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.settings_outlined),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Wifi Ayarları"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomTextField(
                                      controller: ssidcon,
                                      focusNode: ssidFocus,
                                      nextFocus: passwordFocus,
                                      hintText: "Wifi SSID",
                                      icon: Icon(Icons.wifi),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: height * 0.020),
                                      child: CustomTextField(
                                        controller: passwordcon,
                                        focusNode: passwordFocus,
                                        hintText: "Wifi Şifre",
                                        icon: Icon(Icons.lock),
                                        isPassword: true,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Vazgeç"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        wifiSSID = ssidcon.text;
                                        wifiPassword = passwordcon.text;
                                      });
                                      Navigator.pop(context);
                                      await wifiEntegration();
                                    },
                                    child: Text("Kaydet"),
                                  )
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: CustomButton(
              title: "TAMAMLANDI",
              color: goldColor,
              onPressed: () {
                disconnectDevice();
              },
            ),
          ),
        ],
      ),
    );
  }

  startScan() async {
    final canStartScan =
        await WiFiScan.instance.canStartScan(askPermissions: true);
    if (canStartScan == CanStartScan.yes) {
      final isScanning = await WiFiScan.instance.startScan();
      if (isScanning) {
        final canGetScannedResults =
            await WiFiScan.instance.canGetScannedResults(askPermissions: true);
        if (canGetScannedResults == CanGetScannedResults.yes) {
          WiFiScan.instance.onScannedResultsAvailable.listen((results) {
            var list = results.where((a) => a.ssid.isNotEmpty).toList();
            list.sort(
              (a, b) => a.ssid.compareTo(b.ssid),
            );
          });
        }
      }
    }
  }

  init() async {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      var ise = await WiFiForIoTPlugin.isEnabled();
      if (ise) {
        var isc = await WiFiForIoTPlugin.isConnected();
        if (isc) {
          var ssid = await WiFiForIoTPlugin.getSSID();
          if (ssid != null) {
            setState(() {
              connectedSSID = ssid;
              connectionStatus = "Bağlı: $connectedSSID";
            });
          }
          if (chipId > 0) {
            timer.cancel();
            setState(() {
              isConnected = isc;
            });
            CherryToast.success(
              toastPosition: Position.top,
              title:
                  Text("Cihaz bilgileri alındı. Sonraki adıma geçebilirsiniz."),
            ).show(context);
            await deviceEntegration();
          }
        } else {
          setState(() {
            connectionStatus = "Bağlı Cihaz Yok";
          });
        }
      } else {
        setState(() {
          connectionStatus = "Wifi Kapalı";
        });
      }
    });
  }

  Future<void> deviceEntegration() async {
    await WiFiForIoTPlugin.forceWifiUsage(false);
    var devices = await DeviceService.getBoxDevices("chipId");
    var parameters = await ParameterService.getParametersbyType(1);
    if (parameters != null) {
      var mqttModel = MqttConnectionModel(
        mqttHostLocal:
            parameters.firstWhere((p) => p.name == "mqtt_host_local").value,
        mqttHostPublic:
            parameters.firstWhere((p) => p.name == "mqtt_host_public").value,
        mqttPort: int.tryParse(
                parameters.firstWhere((p) => p.name == "mqtt_port").value) ??
            1883,
        mqttUser: parameters.firstWhere((p) => p.name == "mqtt_user").value,
        mqttPassword:
            parameters.firstWhere((p) => p.name == "mqtt_password").value,
        mqttClientId: devices != null
            ? "${devices.box!.id}-${devices.box!.name}"
            : "AA$chipId",
      );
      await WiFiForIoTPlugin.forceWifiUsage(true);
      var uri = Uri.parse("http://192.168.4.1/mqttsettings");
      var client = http.Client();
      client
          .post(
        uri,
        headers: {
          'content-type': 'application/json',
        },
        body: mqttModel.toJson(),
      )
          .then((response) {
        if (response.statusCode == 200) {
          CherryToast.success(
            toastPosition: Position.bottom,
            title: Text(response.body),
          ).show(context);
        } else {
          CherryToast.error(
            toastPosition: Position.bottom,
            title: Text(response.body),
          ).show(context);
        }
      });
    }
    if (devices != null) {
      await WiFiForIoTPlugin.forceWifiUsage(true);
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
          setState(() {
            isEntegration = true;
            entegrationStatus = response.body;
          });
          CherryToast.success(
            toastPosition: Position.bottom,
            title: Text(response.body),
          ).show(context);
        } else {
          CherryToast.error(
            toastPosition: Position.bottom,
            title: Text(response.body),
          ).show(context);
        }
      });
    }
  }

  Future<void> wifiEntegration() async {
    var wifi = WifiModel(ssid: wifiSSID, password: wifiPassword);
    print(wifi.toJson());
    var uri = Uri.parse("http://192.168.4.1/wifisettings");
    var client = http.Client();
    client
        .post(
      uri,
      headers: {
        'content-type': 'application/json',
      },
      body: wifi.toJson(),
    )
        .then((response) {
      if (response.statusCode == 200) {
        setState(() {
          wifiOk = true;
          wifiStatus = response.body;
        });
        CherryToast.success(
          toastPosition: Position.bottom,
          title: Text(response.body),
        ).show(context);
      } else {
        CherryToast.error(
          toastPosition: Position.bottom,
          title: Text(response.body),
        ).show(context);
      }
    });
  }

  Future<void> disconnectDevice() async {
    await WiFiForIoTPlugin.forceWifiUsage(true);
    var uri = Uri.parse("http://192.168.4.1/disconnect");
    var client = http.Client();
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => HomePage(),
        ),
      );
    }
  }
}
