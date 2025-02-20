import 'dart:async';

import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceListViewItemSwitch extends StatefulWidget {
  final HomeDeviceDto device;
  const DeviceListViewItemSwitch({super.key, required this.device});

  @override
  State<DeviceListViewItemSwitch> createState() =>
      _DeviceListViewItemSwitchState();
}

class _DeviceListViewItemSwitchState extends State<DeviceListViewItemSwitch> {
  final MqttController _mqttController = Get.find();
  final HomeController homeController = Get.find();
  late HomeDeviceDto device;
  int openCount = 0;
  int closeCount = 0;
  int waitingCount = 0;
  String status = "";
  Timer? _statusTimer;
  @override
  void initState() {
    super.initState();
    device = widget.device;
    status = homeController.lastStatus[device.id!] ?? "";
    _startStatusTimeout();
    _mqttController.onMessage((topic, message) {
      if (topic == device.topicStat) {
        if (mounted) {
          setState(() {
            status = message;
            if (status == "1") {
              openCount = 0;
              closeCount = 0;
              waitingCount = 0;
            }
            if (status == "2") {
              openCount++;
            }
            if (status == "3") {
              waitingCount++;
            }
            if (status == "4") {
              closeCount++;
            }
          });
          homeController.lastStatus[device.id!] = status;
          _resetStatusTimeout(); // Yeni mesaj alındığında zamanlayıcıyı sıfırla
        }
      }
    });
  }

  void _startStatusTimeout() {
    _statusTimer = Timer(Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          status = "";
        });
        homeController.lastStatus[device.id!] = status;
      }
    });
  }

  void _resetStatusTimeout() {
    _statusTimer?.cancel(); // Önceki zamanlayıcıyı iptal et
    _startStatusTimeout(); // Yeni zamanlayıcı başlat
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Opacity(
          opacity: status == "" ? 0.5 : 1,
          child: Switch(
            activeColor: goldColor,
            value: false,
            onChanged: (value) {
              //
            },
          ),
        ),
      ],
    );
  }
}
