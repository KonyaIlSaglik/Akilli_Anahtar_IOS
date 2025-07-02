import 'dart:async';

import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/loading_dots.dart';
import 'package:akilli_anahtar/widgets/connection_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DeviceListViewItemAction extends StatefulWidget {
  final HomeDeviceDto device;
  const DeviceListViewItemAction({super.key, required this.device});

  @override
  State<DeviceListViewItemAction> createState() =>
      _DeviceListViewItemActionState();
}

class _DeviceListViewItemActionState extends State<DeviceListViewItemAction>
    with WidgetsBindingObserver {
  final MqttController _mqttController = Get.find();
  final HomeController homeController = Get.find();
  late HomeDeviceDto device;
  int openCount = 0;
  int closeCount = 0;
  int waitingCount = 0;
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
        if (mounted) {
          setState(() {
            _connectionError = false;
            homeController.connectionErrors[device.id!] = false;
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
      openCount = 0;
      closeCount = 0;
      waitingCount = 0;
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
          child: Card(
            elevation: 0,
            shape: CircleBorder(),
            color: device.typeId == 4 || device.typeId == 6
                ? status == "1"
                    ? Colors.red[400]
                    : status == "2"
                        ? Colors.brown[50]!
                        : status == "3"
                            ? waitingCount.isOdd
                                ? Colors.brown[50]!
                                : Colors.green
                            : status == "4"
                                ? Colors.brown[50]!
                                : Colors.red[400]
                : device.typeId == 5 || device.typeId == 8
                    ? status == "0"
                        ? Colors.brown[50]!
                        : Colors.red[400]
                    : status == "1"
                        ? Colors.brown[50]!
                        : Colors.red[400],
            child: CircularPercentIndicator(
              radius: width(context) * 0.05,
              percent: status == "2"
                  ? openCount / device.openingTime!
                  : status == "4"
                      ? closeCount / device.closingTime!
                      : waitingCount.isEven
                          ? 1
                          : 1,
              progressColor: status == "2" || status == "3"
                  ? Colors.green
                  : Colors.red[400],
              backgroundColor: Colors.brown[50]!,
              lineWidth: width(context) * 0.006,
              center: status.isNotEmpty
                  ? Icon(
                      FontAwesomeIcons.powerOff,
                      color: status == "2"
                          ? Colors.green
                          : status == "3"
                              ? waitingCount.isOdd
                                  ? Colors.green
                                  : Colors.brown[50]!
                              : status == "4"
                                  ? Colors.red[400]
                                  : Colors.brown[50]!,
                      size: width(context) * 0.06,
                    )
                  : _connectionError
                      ? Icon(
                          Icons.error_outline,
                          color: Colors.red[800],
                          size: width(context) * 0.06,
                        )
                      : LoadingDots(
                          color: Colors.grey[800],
                          size: 4.0,
                        ),
            ),
          ),
        ),
        if (status.isNotEmpty)
          Text(
            status == "1"
                ? "Kapalı"
                : status == "2"
                    ? "Açılıyor"
                    : status == "3"
                        ? "Açık"
                        : status == "4"
                            ? "Kapanıyor"
                            : "-",
            style: textTheme(context).labelMedium,
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
}
