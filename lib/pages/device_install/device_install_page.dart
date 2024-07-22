import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;

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
        WiFiForIoTPlugin.findAndConnect("AKILLI_ANAHTAR11",
                password: "12345678")
            .then((value) {
          print("sgseghsegse" + value.toString());
          setState(() {
            isConnected = value;
          });
          if (value) {
            print("parametreler gonderiliyor");
            var uri = Uri.parse(
                "http://192.168.4.1/wifisave?s=AKILLI_ANAHTAR&p=12345678&config=buradanbilgilergonderilecek");
            var client = http.Client();
            client.post(uri).then((response) {
              print(response.statusCode);
            });
          }
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
