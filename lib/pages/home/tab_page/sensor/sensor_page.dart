import 'package:akilli_anahtar/controllers/device_controller.dart';
import 'package:akilli_anahtar/models/sensor_device_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';
import 'package:get/get.dart';

import 'sensor_list_item.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({Key? key}) : super(key: key);

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  final DeviceController _deviceController = Get.find<DeviceController>();
  List<SensorDeviceModel> sensorList = [];
  @override
  void initState() {
    super.initState();
    sensorList = _deviceController.sensorDevices;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _deviceController.loadingSensorDevices.value
          ? Center(
              child: CircularProgressIndicator(),
            )
          : sensorList.isEmpty
              ? Center(
                  child: Text("Sensor Listesi Boş"),
                )
              : MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(0.90)),
                  child: WallLayout(
                      stonePadding: 5,
                      reverse: false,
                      layersCount: 4,
                      scrollDirection: Axis.vertical,
                      stones: List<Stone>.generate(sensorList.length, (index) {
                        var sensor = sensorList[index];
                        return Stone(
                          id: sensor.id!,
                          height: 1,
                          width: 4,
                          child: SensorListItem(
                            device: sensor,
                          ),
                        );
                      })),
                );
    });
  }

  // getSensorler() async {
  //   sensorList.clear();
  //   var info = await LocalDb.get(userKey);
  //   var id = User.fromJson(info!).id;
  //   var boxes = await DeviceService.getUserDevices(id) ?? [];
  //   var kList = <Sensor>[];
  //   for (var box in boxes) {
  //     if (box.relays.isNotEmpty) {
  //       kList.addAll(box.sensors);
  //     }
  //   }
  //   for (var i = 0; i < kList.length; i++) {
  //     kList[i].topicMessage = "-";
  //   }
  //   await Future.delayed(Duration(seconds: 1));
  //   for (var k in kList) {
  //     client!.sub(k.topicStat);
  //   }
  //   setState(() {
  //     kList.sort(
  //       (a, b) => b.id.compareTo(a.id),
  //     );
  //     sensorList.addAll(kList);
  //     loading = false;
  //   });
  // }

  List<Stone> getSensorWidgetList() {
    var list = List<Stone>.empty(growable: true);

    // for (var sensor in sensorList) {
    //   list.add(Stone(
    //     id: sensor.id,
    //     height: 1,
    //     width: 4,
    //     child: SensorListItem(
    //       id: sensor.id,
    //       adi: sensor.name,
    //       kurum: "-",
    //       durum: "Bağlı",
    //       deger: sensor.topicMessage,
    //       birim: sensor.unit,
    //       baglanti: 1,
    //     ),
    //   ));
    // }

    return list;
  }

  @override
  void onMessage(String topic, String message) {
    print("$topic --> $message");
    setState(() {
      var sensor = sensorList.singleWhere((k) => k.topicStat == topic);
      setState(() {
        //sensor.topicMessage = json.decode(message)["deger"].toString();
      });
    });
  }
}
