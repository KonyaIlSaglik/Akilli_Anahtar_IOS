import 'dart:convert';

import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceListViewItemInfo extends StatefulWidget {
  final HomeDeviceDto device;
  const DeviceListViewItemInfo({
    super.key,
    required this.device,
  });

  @override
  State<DeviceListViewItemInfo> createState() => _DeviceListViewItemInfoState();
}

class _DeviceListViewItemInfoState extends State<DeviceListViewItemInfo> {
  final MqttController _mqttController = Get.find();
  final HomeController homeController = Get.find();
  late HomeDeviceDto device;

  int alarmStatus = 0;
  String status = "";
  @override
  void initState() {
    super.initState();
    device = widget.device;
    status = homeController.lastStatus[device.id!] ?? "";
    _mqttController.onMessage((topic, message) {
      if (topic == device.topicStat) {
        if (mounted) {
          setState(() {
            if (device.typeId == 1 ||
                device.typeId == 2 ||
                device.typeId == 3) {
              if (message.contains("{")) {
                final dynamic data;
                device.typeId! < 3
                    ? data = json.decode(message)["deger"] as double
                    : data = json.decode(message)["deger"] as int;
                status = data.toString();
                var dData = double.parse(status);
                alarmStatus = 0;
                if (device.normalMaxValue != null &&
                    dData > device.normalMaxValue!) {
                  alarmStatus = 1;
                }
                if (device.criticalMaxValue != null &&
                    dData > device.criticalMaxValue!) {
                  alarmStatus = 2;
                }
              }
            }
          });
          homeController.lastStatus[device.id!] = status;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          status.isNotEmpty ? status : "-",
          style: textTheme(context).headlineLarge!.copyWith(
                color: alarmStatus == 1
                    ? Colors.white
                    : alarmStatus == 2
                        ? Colors.red
                        : Colors.black,
              ),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          device.unit ?? "-",
          style: TextStyle(
            color: alarmStatus == 1
                ? Colors.white
                : alarmStatus == 2
                    ? Colors.red
                    : Colors.black,
          ),
        ),
      ],
    );
  }
}
