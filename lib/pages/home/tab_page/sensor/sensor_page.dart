import 'dart:convert';

import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/kullanici_sensor.dart';
import 'package:akilli_anahtar/services/api/device_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/services/web/mqtt_listener.dart';
import 'package:akilli_anahtar/services/web/my_mqtt_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';

import 'sensor_list_item.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({Key? key}) : super(key: key);

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> implements IMqttSubListener {
  MyMqttClient? client = MyMqttClient.instance;
  bool loading = true;
  List<KullaniciSensor> sensorList = [];
  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    getSensorler();
    client!.setSubListener(this);
    client!.listen();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(0.90)),
            child: WallLayout(
              stonePadding: 5,
              reverse: false,
              layersCount: 4,
              scrollDirection: Axis.vertical,
              stones: getSensorWidgetList(),
            ),
          );
  }

  getSensorler() async {
    sensorList.clear();
    var info = await LocalDb.get(userKey);
    var id = User.fromJson(info!).id;
    var kList = await DeviceService.getKullaniciSensor(id!) ?? [];
    for (var i = 0; i < kList.length; i++) {
      kList[i].topicMessage = "-";
    }
    await Future.delayed(Duration(seconds: 1));
    for (var k in kList) {
      client!.sub(k.topicStat);
    }
    setState(() {
      kList.sort(
        (a, b) => b.sensorId.compareTo(a.sensorId),
      );
      sensorList.addAll(kList);
      loading = false;
    });
  }

  List<Stone> getSensorWidgetList() {
    var list = List<Stone>.empty(growable: true);

    for (var sensor in sensorList) {
      list.add(Stone(
        id: sensor.sensorId,
        height: 1,
        width: 4,
        child: SensorListItem(
          id: sensor.sensorId,
          adi: sensor.sensorName,
          kurum: sensor.kurumAdi,
          durum: "Bağlı",
          deger: sensor.topicMessage,
          birim: sensor.birim,
          baglanti: 1,
        ),
      ));
    }

    return list;
  }

  @override
  void onMessage(String topic, String message) {
    print("$topic --> $message");
    setState(() {
      var sensor = sensorList.singleWhere((k) => k.topicStat == topic);
      setState(() {
        sensor.topicMessage = json.decode(message)["deger"].toString();
      });
    });
  }
}
