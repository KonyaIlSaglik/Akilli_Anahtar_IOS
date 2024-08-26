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
  final DeviceController _deviceController = Get.put(DeviceController());
  List<SensorDeviceModel> sensorList = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _deviceController.getSensorDevices().then((value) {
      setState(() {
        sensorList = _deviceController.sensorDevices;
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          loading = true;
        });
        await _deviceController.getSensorDevices();
        if (mounted) {
          setState(() {
            sensorList = _deviceController.sensorDevices;
            loading = false;
          });
        }
      },
      child: loading
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
                  child: Obx(() {
                    return WallLayout(
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
                            sensor: sensor,
                          ),
                        );
                      }),
                    );
                  }),
                ),
    );
  }

  List<Stone> getSensorWidgetList() {
    var list = List<Stone>.empty(growable: true);

    return list;
  }
}
