import 'package:akilli_anahtar/controllers/device_controller.dart';
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
  DeviceController deviceController = Get.find();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await deviceController.getUserDevices();
      },
      child: Obx(() {
        return deviceController.loadingSensorDevices.value
            ? Center(
                child: CircularProgressIndicator(),
              )
            : deviceController.sensorDevices.isEmpty
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
                      stones: List<Stone>.generate(
                          deviceController.sensorDevices.length, (index) {
                        var sensor = deviceController.sensorDevices[index];
                        return Stone(
                          id: sensor.id,
                          height: 1,
                          width: 4,
                          child: SensorListItem(
                            sensor: sensor,
                          ),
                        );
                      }),
                    ),
                  );
      }),
    );
  }

  List<Stone> getSensorWidgetList() {
    var list = List<Stone>.empty(growable: true);

    return list;
  }
}
