import 'dart:async';
import 'dart:convert';

import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/loading_dots.dart';
import 'package:akilli_anahtar/widgets/connection_error_widget.dart';
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
  Timer? _statusTimer;
  bool _connectionError = false;

  @override
  void initState() {
    super.initState();
    device = widget.device;
    status = homeController.lastStatus[device.id!] ?? "";

    _connectionError = homeController.connectionErrors[device.id!] ?? false;

    if (!_connectionError && status.isEmpty) {
      _startStatusTimeout();
    }

    _mqttController.onMessage((topic, message) {
      if (topic == device.topicStat) {
        if (mounted) {
          setState(() {
            _connectionError = false;
            homeController.connectionErrors[device.id!] = false;
            if (device.typeId == 1 ||
                device.typeId == 2 ||
                device.typeId == 3) {
              if (message.startsWith("{") && !message.endsWith(":}")) {
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
          _resetStatusTimeout();
        }
      }
    });
    print("${device.topicRec} -->  get");
    _mqttController.publishMessage(device.topicRec!, "get");
  }

  void _startStatusTimeout() {
    _statusTimer = Timer(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          status = "";
          alarmStatus = 0;
          _connectionError = true;
          homeController.connectionErrors[device.id!] = true;
        });
        homeController.lastStatus[device.id!] = status;
        _statusTimer?.cancel();
      }
    });
  }

  void _resetStatusTimeout() {
    _statusTimer?.cancel();
    if (!_connectionError) {
      _startStatusTimeout();
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (status.isNotEmpty)
          Text(
            status,
            style: textTheme(context).headlineLarge!.copyWith(
                  color: alarmStatus == 1
                      ? Colors.orange
                      : alarmStatus == 2
                          ? Colors.red
                          : Colors.black,
                ),
          )
        else if (_connectionError)
          ConnectionErrorWidget(
            fontSize: 10.0,
            color: Colors.red[800],
          )
        else
          LoadingDots(
            color: Colors.grey[800],
            size: 6.0,
          ),
        if (status.isNotEmpty) ...[
          SizedBox(
            width: 5,
          ),
          Text(
            device.unit ?? "-",
            style: TextStyle(
              color: alarmStatus == 1
                  ? Colors.orange
                  : alarmStatus == 2
                      ? Colors.red
                      : Colors.black,
            ),
          ),
        ],
      ],
    );
  }
}
