import 'dart:async';

import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

class NodemcuInstallPage extends StatefulWidget {
  const NodemcuInstallPage({Key? key}) : super(key: key);

  @override
  State<NodemcuInstallPage> createState() => _NodemcuInstallPageState();
}

class _NodemcuInstallPageState extends State<NodemcuInstallPage> {
  bool isConnected = false;
  String connectionStatus = "-";
  String connectedSSID = "";
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      var ise = await WiFiForIoTPlugin.isEnabled();
      if (ise) {
        var isc = await WiFiForIoTPlugin.isConnected();
        if (isc) {
          setState(() {
            isConnected = isc;
            connectionStatus = "Bağlı: -";
          });
          var ssid = await WiFiForIoTPlugin.getSSID();
          if (ssid != null) {
            setState(() {
              connectedSSID = ssid;
              connectionStatus = "Bağlı: $connectedSSID";
            });
          }
        }
      } else {
        setState(() {
          connectionStatus = "Wifi Kapalı";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        children: [
          ListTile(
            leading: Icon(isConnected ? Icons.done : Icons.close),
            title: Text("Akıllı Anahtar Cihaz Bağlantısı"),
            subtitle: Text(connectionStatus),
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
            leading: Icon(Icons.close),
            title: Text("Cihaz Entegrasyonu"),
            subtitle: Text("Entegrasyon yapılmadı"),
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
                  onPressed: () {
                    //
                  },
                ),
              ],
            ),
          ),
          ListTile(
            enabled: false,
            leading: Icon(Icons.close),
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
                  icon: Icon(Icons.chevron_right_outlined),
                  onPressed: () {
                    //
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
