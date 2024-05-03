import 'package:akilli_anahtar/models/kullanici_giris_result.dart';
import 'package:akilli_anahtar/pages/home/tab_page/sensor/sensor_page.dart';
import 'package:akilli_anahtar/services/web/mqtt_listener.dart';
import 'package:akilli_anahtar/services/web/my_mqtt_service.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import '../../../utils/constants.dart';
import 'bahce/bahce_page.dart';
import 'kapi/kapi_page.dart';

class TabView extends StatefulWidget {
  final KullaniciGirisResult user;
  const TabView({Key? key, required this.user}) : super(key: key);

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> implements IMqttConnListener {
  bool loading = true;
  int windowState = 1;
  MyMqttClient? client = MyMqttClient.instance;
  @override
  void initState() {
    super.initState();
    client!.setConnListener(this);
    if (client!.state == MqttConnectionState.disconnected) {
      client!.connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return FocusDetector(
      onFocusGained: () async {
        if (client!.state == MqttConnectionState.disconnected) {
          setState(() {
            loading = true;
          });
          client!.connect();
        }
      },
      onFocusLost: () {
        if (client!.state == MqttConnectionState.connected) {
          client!.disconnect();
        }
      },
      child: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Column(
          children: [
            Expanded(
              child: loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: mainColor,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TabBarView(
                        children: [
                          KapiPage(user: widget.user),
                          BahcePage(),
                          SensorPage(),
                        ],
                      ),
                    ),
            ),
            SizedBox(
              height: height * 0.1,
              child: Container(
                color: mainColor,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.menu), Text("Menü")],
                        ),
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TabBar(
                        dividerHeight: 0,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.black45,
                        indicatorColor: Colors.transparent,
                        tabs: [
                          Tab(text: 'KAPI', icon: Icon(Icons.sensor_door)),
                          Tab(text: 'BAHÇE', icon: Icon(Icons.sunny)),
                          Tab(text: 'SENSÖR', icon: Icon(Icons.sensors)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void connected(String server) {
    setState(() {
      print("$server bağlandı");
      windowState = 1;
      loading = false;
    });
  }

  @override
  void disconnected(String server) {
    print("$server bağlantı kesildi");
  }
}
