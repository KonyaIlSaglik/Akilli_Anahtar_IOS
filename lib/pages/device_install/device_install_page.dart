import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

class DeviceInstallPage extends StatefulWidget {
  const DeviceInstallPage({Key? key}) : super(key: key);

  @override
  State<DeviceInstallPage> createState() => _DeviceInstallPageState();
}

class _DeviceInstallPageState extends State<DeviceInstallPage> {
  bool isConnected = false;
  @override
  void initState() {
    super.initState();
    WiFiForIoTPlugin.isEnabled().then((value) {
      if (value) {
        WiFiForIoTPlugin.connect("car", password: "").then((value) {
          print("sgseghsegse");
          setState(() {
            isConnected = value;
          });
        });
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: isConnected
            ? Text(isConnected ? "Bağlı" : "Bağlı Değil")
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
