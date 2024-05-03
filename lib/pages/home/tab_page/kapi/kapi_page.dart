import 'package:akilli_anahtar/models/kullanici_giris_result.dart';
import 'package:akilli_anahtar/pages/home/tab_page/kapi/kapi_grid_view.dart';
import 'package:flutter/material.dart';

import '../../../../models/kullanici_kapi_result.dart';
import '../../../../services/web/mqtt_listener.dart';
import '../../../../services/web/my_mqtt_service.dart';
import '../../../../services/web/web_service.dart';
import '../../../../utils/constants.dart';

class KapiPage extends StatefulWidget {
  final KullaniciGirisResult user;
  const KapiPage({Key? key, required this.user}) : super(key: key);

  @override
  State<KapiPage> createState() => _KapiPageState();
}

class _KapiPageState extends State<KapiPage> implements IMqttSubListener {
  MyMqttClient? client = MyMqttClient.instance;
  bool loading = true;
  List<KullaniciKapiResult> kapilar = [];
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
      color: mainColor,
      onRefresh: () async {
        print("Yenileniyor");
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
    var kList = await WebService.kullaniciKapi(widget.user.id!) ?? [];
    for (var i = 0; i < kList.length; i++) {
      kList[i].topicMessage = "KAPALI";
    }
    await Future.delayed(Duration(seconds: 1));
    for (var k in kList) {
      client!.sub(k.topicStat!);
    }
    setState(() {
      kList.sort(
        (a, b) => b.kapiId!.compareTo(a.kapiId!),
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
