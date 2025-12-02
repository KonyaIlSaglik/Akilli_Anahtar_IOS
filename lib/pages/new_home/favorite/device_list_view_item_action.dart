import 'dart:async';
import 'dart:convert';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DeviceListViewItemAction extends StatefulWidget {
  final HomeDeviceDto device;
  final VoidCallback? onPowerTap;

  const DeviceListViewItemAction({
    super.key,
    required this.device,
    this.onPowerTap,
  });

  @override
  State<DeviceListViewItemAction> createState() =>
      _DeviceListViewItemActionState();
}

class _DeviceListViewItemActionState extends State<DeviceListViewItemAction> {
  final MqttController _mqtt = Get.find();

  HomeController? _home;
  late HomeDeviceDto device;

  String status = "";
  int openCount = 0;
  int closeCount = 0;
  int waitingCount = 0;

  StreamSubscription? _sub;
  Timer? _retainedCheckTimer;

  bool _toggle01 = false;
  Timer? _toggleTimer;

  @override
  void initState() {
    super.initState();
    device = widget.device;

    _toggleTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() => _toggle01 = !_toggle01);
    });

    if (Get.isRegistered<HomeController>()) {
      _home = Get.find<HomeController>();
      status = _home?.lastStatus[device.id!] ?? "";
    }
    _checkForExistingStatus();

    if (device.topicStat != null && device.topicStat!.isNotEmpty) {
      _mqtt.subscribeToTopic(device.topicStat!);

      _retainedCheckTimer = Timer(const Duration(milliseconds: 500), () {
        _checkForExistingStatus();
      });
    }

    _sub = _mqtt.client.updates.listen((events) {
      if (!mounted || events.isEmpty) return;
      final msg = events.first;
      final topic = msg.topic.toString();
      if (topic != device.topicStat) return;

      final pub = msg.payload as MqttPublishMessage;
      final text = const Utf8Decoder().convert(pub.payload.message!).trim();

      _updateStatus(text);
    });
  }

  void _checkForExistingStatus() {
    if (!mounted) return;

    final lastStatus = _mqtt.getDeviceLastStatus(device);
    if (lastStatus != null && lastStatus.isNotEmpty) {
      _updateStatus(lastStatus);
    }
  }

  void _updateStatus(String newStatus) {
    if (!mounted) return;

    setState(() {
      status = newStatus;
      if (status == "1") {
        openCount = 0;
        closeCount = 0;
        waitingCount = 0;
      } else if (status == "2") {
        final max = (device.openingTime ?? 1);
        openCount = (openCount + 1).clamp(0, max);
      } else if (status == "3") {
        waitingCount++;
      } else if (status == "4") {
        final max = (device.closingTime ?? 1);
        closeCount = (closeCount + 1).clamp(0, max);
      }
    });

    _home?.lastStatus[device.id!] = newStatus;
  }

  @override
  void dispose() {
    _retainedCheckTimer?.cancel();
    _toggleTimer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool offline = _mqtt.isDeviceOffline(device);
      final Color bgColor = _backgroundColor(offline);
      final Color progressColor = _progressColor(offline);
      final Color iconColor = _iconColor(offline);
      final double percent = _percentValue().clamp(0.0, 1.0);

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
              opacity: offline ? 0.6 : (status.isEmpty ? 0.85 : 1.0),
              child: Card(
                elevation: 0,
                shape: const CircleBorder(),
                color: bgColor,
                child: SizedBox(
                  width: width(context) * 0.1,
                  height: width(context) * 0.1,
                  child: GestureDetector(
                    onTap: () {
                      print("Power butona tıklandı!");
                    },
                    child: CircularPercentIndicator(
                      radius: width(context) * 0.05,
                      percent: percent,
                      progressColor: progressColor,
                      backgroundColor: Colors.brown[50]!,
                      lineWidth: width(context) * 0.006,
                      center: Icon(
                        FontAwesomeIcons.powerOff,
                        color: iconColor,
                        size: width(context) * 0.06,
                      ),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 4),
          Text(
            _labelText(offline),
            style: textTheme(context).labelMedium,
          ),
        ],
      );
    });
  }

  double _percentValue() {
    if (status == "2" || status == "3" || status == "4") {
      return _toggle01 ? 1.0 : 0.0;
    }
    return 1.0;
  }

  String _labelText(bool offline) {
    if (offline) return "";
    return status == "1"
        ? "Kapalı"
        : status == "2"
            ? "Açılıyor"
            : status == "3"
                ? "Açık"
                : status == "4"
                    ? "Kapanıyor"
                    : status.isEmpty
                        ? "Yükleniyor..."
                        : " ";
  }

  Color _backgroundColor(bool offline) {
    if (offline) return Colors.grey.shade300;

    if (device.typeId == 4 || device.typeId == 6) {
      if (status == "1") return Colors.red[400]!;
      if (status == "2") return Colors.brown[50]!;
      if (status == "3")
        return waitingCount.isOdd ? Colors.brown[50]! : Colors.green;
      if (status == "4") return Colors.brown[50]!;
      return Colors.red[400]!;
    } else if (device.typeId == 5 ||
        device.typeId == 8 ||
        device.typeId == 10) {
      return status == "0" ? Colors.brown[50]! : Colors.red[400]!;
    } else {
      return status == "1" ? Colors.brown[50]! : Colors.red[400]!;
    }
  }

  Color _progressColor(bool offline) {
    if (offline) return Colors.grey;
    if (status == "2" || status == "3") return Colors.green;
    return Colors.red[400]!;
  }

  Color _iconColor(bool offline) {
    if (offline) return Colors.white70;
    if (status == "2") return Colors.green;
    if (status == "3")
      return waitingCount.isOdd ? Colors.green : Colors.brown[50]!;
    if (status == "4") return Colors.red[400]!;
    return Colors.brown[50]!;
  }
}
