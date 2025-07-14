import 'dart:async';

import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/loading_dots.dart';
import 'package:akilli_anahtar/widgets/connection_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceListViewItemSwitch extends StatefulWidget {
  final HomeDeviceDto device;
  const DeviceListViewItemSwitch({super.key, required this.device});

  @override
  State<DeviceListViewItemSwitch> createState() =>
      _DeviceListViewItemSwitchState();
}

class _DeviceListViewItemSwitchState extends State<DeviceListViewItemSwitch>
    with WidgetsBindingObserver {
  final MqttController _mqttController = Get.find();
  final HomeController homeController = Get.find();
  late HomeDeviceDto device;
  String status = "";
  Timer? _statusTimer;
  bool _connectionError = false;
  bool _wasPaused = false;
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    device = widget.device;
    status = homeController.lastStatus[device.id!] ?? "";

    _connectionError = homeController.connectionErrors[device.id!] ?? false;

    if (!_connectionError && status.isEmpty) {
      _startStatusTimeout();
    }

    _mqttController.onMessage((topic, message) {
      if (topic == device.topicStat) {
        //print("$topic: $message");
        if (mounted) {
          setState(() {
            _connectionError = false;
            homeController.connectionErrors[device.id!] = false;
            status = message;
          });
          homeController.lastStatus[device.id!] = status;
          _resetStatusTimeout();
        }
      }
    });
  }

  void _startStatusTimeout() {
    _statusTimer = Timer(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          status = "";
          _connectionError = true;
          homeController.connectionErrors[device.id!] = true;
          homeController.lastStatus[device.id!] = "";
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

  void _handleAppResumed() async {
    setState(() {
      _connectionError = false;
      homeController.connectionErrors[device.id!] = false;
      status = "";
      _statusTimer?.cancel();
      _startStatusTimeout();
    });
    if (!_mqttController.isConnected.value) {
      await _mqttController.connect();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasPaused = true;
      _pausedTime = DateTime.now();
    }
    if (state == AppLifecycleState.resumed && _wasPaused) {
      if (_pausedTime != null &&
          DateTime.now().difference(_pausedTime!).inSeconds > 30) {
        _handleAppResumed();
      }
      _wasPaused = false;
      _pausedTime = null;
    }
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
            value: device.typeId == 5
                ? status == "1"
                    ? false
                    : true
                : status == "0"
                    ? false
                    : true,
            onChanged: (value) {
              //
            },
          ),
        ),
        if (status.isNotEmpty)
          Text(
            device.typeId == 5
                ? status == "1"
                    ? "Kapalı"
                    : "Açık"
                : status == "0"
                    ? "Kapalı"
                    : formatDuration(status),
            style: textTheme(context).labelMedium?.copyWith(
                fontWeight: device.typeId == 5 || status == "0"
                    ? FontWeight.normal
                    : FontWeight.bold,
                color: device.typeId == 5 || status == "0"
                    ? Colors.black
                    : Colors.red),
          )
        else if (_connectionError)
          ConnectionErrorWidget(
            fontSize: 8.0,
            color: Colors.red[800],
          )
        else
          LoadingDots(
            color: Colors.grey[800],
            size: 4.0,
          ),
      ],
    );
  }

  String formatDuration(String status) {
    // String'i int'e çevir
    int seconds = int.tryParse(status) ?? 0;

    // Saat, dakika ve saniye hesaplama
    int hours = seconds ~/ 3600;
    seconds %= 3600;
    int minutes = seconds ~/ 60;
    seconds %= 60;
    String sa = hours < 10 ? "0$hours" : "$hours";
    String dk = minutes < 10 ? "0$minutes" : "$minutes";
    String sn = seconds < 10 ? "0$seconds" : "$seconds";
    // Formatı oluştur
    return '$sa:$dk:$sn';
  }
}
