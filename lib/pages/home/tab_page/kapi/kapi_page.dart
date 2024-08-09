import 'package:akilli_anahtar/entities/relay.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/pages/home/tab_page/kapi/kapi_grid_view.dart';
import 'package:akilli_anahtar/services/api/device_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';

import '../../../../services/web/mqtt_listener.dart';
import '../../../../services/web/my_mqtt_service.dart';

class KapiPage extends StatefulWidget {
  const KapiPage({Key? key}) : super(key: key);

  @override
  State<KapiPage> createState() => _KapiPageState();
}

class _KapiPageState extends State<KapiPage> implements IMqttSubListener {
  MyMqttClient? client = MyMqttClient.instance;
  bool loading = true;
  List<Relay> kapilar = [];
  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    getKapilar();
    client!.setSubListener(this);
    client!.listen();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          loading = true;
        });
        init();
      },
      child: KapiGridView(kapilar: kapilar),
    );
  }

  getKapilar() async {
    kapilar.clear();
    var info = await LocalDb.get(userKey);
    var id = User.fromJson(info!).id;
    var boxes = await DeviceService.getUserDevices(id) ?? [];
    var kList = <Relay>[];
    for (var box in boxes) {
      if (box.relays.isNotEmpty) {
        kList.addAll(box.relays);
      }
    }
    for (var i = 0; i < kList.length; i++) {
      kList[i].topicMessage = "KAPALI";
    }
    await Future.delayed(Duration(seconds: 1));
    for (var k in kList) {
      client!.sub(k.topicStat);
    }
    setState(() {
      kList.sort(
        (a, b) => b.id.compareTo(a.id),
      );
      kapilar.addAll(kList);
      loading = false;
    });
  }

  @override
  void onMessage(String topic, String message) {
    print("$topic --> $message");
    setState(() {
      var kapi = kapilar.singleWhere((k) => k.topicStat == topic);
      setState(() {
        kapi.topicMessage = message;
      });
    });
  }
}
