import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'package:wifi_scan/wifi_scan.dart';

class DeviceInstallPage extends StatefulWidget {
  const DeviceInstallPage({Key? key}) : super(key: key);

  @override
  State<DeviceInstallPage> createState() => _DeviceInstallPageState();
}

class _DeviceInstallPageState extends State<DeviceInstallPage> {
  bool isConnected = false;
  bool scanning = true;
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  @override
  void initState() {
    super.initState();
    startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  }

  startScan() {
    setState(() {
      scanning = true;
    });
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
}

class AccessPointTile extends StatelessWidget {
  final WiFiAccessPoint accessPoint;

  const AccessPointTile({Key? key, required this.accessPoint})
      : super(key: key);

  // build row that can display info, based on label: value pair.
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
    final title = accessPoint.ssid.isNotEmpty ? accessPoint.ssid : "**EMPTY**";
    final signalIcon = accessPoint.level >= -80
        ? Icons.wifi_outlined
        : Icons.wifi_2_bar_outlined;
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Icon(signalIcon),
      title: Text(title),
      subtitle: Text(accessPoint.capabilities),
      trailing: IconButton(
        icon: Icon(Icons.info_outline),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(accessPoint.ssid),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfo("BSSDI", accessPoint.bssid),
                _buildInfo("Capability", accessPoint.capabilities),
                _buildInfo("frequency", "${accessPoint.frequency}MHz"),
                _buildInfo("level", accessPoint.level),
                _buildInfo("standard", accessPoint.standard),
                _buildInfo(
                    "centerFrequency0", "${accessPoint.centerFrequency0}MHz"),
                _buildInfo(
                    "centerFrequency1", "${accessPoint.centerFrequency1}MHz"),
                _buildInfo("channelWidth", accessPoint.channelWidth),
                _buildInfo("isPasspoint", accessPoint.isPasspoint),
                _buildInfo(
                    "operatorFriendlyName", accessPoint.operatorFriendlyName),
                _buildInfo("venueName", accessPoint.venueName),
                _buildInfo(
                    "is80211mcResponder", accessPoint.is80211mcResponder),
              ],
            ),
          ),
        ),
      ),
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(),
              ElevatedButton(
                child: Text("BAĞLAN"),
                onPressed: () {
                  WiFiForIoTPlugin.isEnabled().then((value) {
                    if (value) {
                      WiFiForIoTPlugin.findAndConnect(title,
                              password: "AA123456")
                          .then((value) {
                        print("sgseghsegse$value");
                        // if (value) {
                        //   print("parametreler gonderiliyor");
                        //   var uri = Uri.parse(
                        //       "http://192.168.4.1/wifisave?s=AKILLI_ANAHTAR&p=12345678&config=buradanbilgilergonderilecek");
                        //   var client = http.Client();
                        //   client.post(uri).then((response) {
                        //     print(response.statusCode);
                        //   });
                        // }
                      });
                    } else {}
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
