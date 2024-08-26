import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/controllers/device_controller.dart';
import 'package:akilli_anahtar/pages/home/tab_page/kapi/control_devices_page.dart';
import 'package:akilli_anahtar/pages/home/tab_page/sensor/sensor_page.dart';
import 'package:akilli_anahtar/services/web/mqtt_listener.dart';
import 'package:akilli_anahtar/services/web/my_mqtt_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'bahce/bahce_page.dart';

class TabView extends StatefulWidget {
  const TabView({Key? key}) : super(key: key);

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView>
    with SingleTickerProviderStateMixin
    implements IMqttConnListener {
  final List<bool> _isDisabled = [true, true, true];
  late TabController _tabController;
  bool loading = true;
  int windowState = 1;
  MyMqttClient? client = MyMqttClient.instance;
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();

    Get.put(DeviceController());

    _isDisabled[0] = !_authController.operationClaims
        .any((c) => c.name == "developer" || c.name == "door_menu");
    _isDisabled[1] = !_authController.operationClaims
        .any((c) => c.name == "developer" || c.name == "sensor_menu");
    _isDisabled[2] = !_authController.operationClaims
        .any((c) => c.name == "developer" || c.name == "garden_menu");

    _tabController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    );

    _tabController.addListener(onTap);
    client!.setConnListener(this);
    if (client!.state == MqttConnectionState.disconnected) {
      client!.connect();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  onTap() {
    if (_isDisabled[_tabController.index]) {
      int index = _tabController.previousIndex;
      setState(() {
        _tabController.index = index;
      });
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
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TabBarView(
                        controller: _tabController,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          ControlDevicesPage(),
                          SensorPage(),
                          BahcePage(),
                        ],
                      ),
                    ),
            ),
            Container(
              color: goldColor,
              height: height * 0.08,
              child: TabBar(
                controller: _tabController,
                dividerHeight: 0,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black45,
                indicatorColor: Colors.transparent,
                tabs: [
                  Tab(
                    text: 'KAPI',
                    icon: Icon(Icons.sensor_door),
                    iconMargin: EdgeInsets.only(top: height * 0.005),
                  ),
                  Tab(
                    text: 'SENSÖR',
                    icon: Icon(Icons.sensors),
                    iconMargin: EdgeInsets.only(top: height * 0.005),
                  ),
                  Tab(
                    text: 'BAHÇE',
                    icon: Icon(Icons.sunny),
                    iconMargin: EdgeInsets.only(top: height * 0.005),
                  ),
                ],
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
