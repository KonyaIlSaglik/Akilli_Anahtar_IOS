import 'dart:async';
import 'dart:convert';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

class DeviceListViewItemSwitch extends StatefulWidget {
  final HomeDeviceDto device;
  const DeviceListViewItemSwitch({super.key, required this.device});

  @override
  State<DeviceListViewItemSwitch> createState() =>
      _DeviceListViewItemSwitchState();
}

class _DeviceListViewItemSwitchState extends State<DeviceListViewItemSwitch> {
  final MqttController _mqtt = Get.find<MqttController>();
  HomeController? _home;
  late HomeDeviceDto device;

  String status = "";
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _sub;
  Timer? _retainedCheckTimer;

  @override
  void initState() {
    super.initState();
    device = widget.device;

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
      final topic = msg.topic.toString().trim();
      if (topic != (device.topicStat ?? '').trim()) return;

      final pub = msg.payload as MqttPublishMessage;
      final text = const Utf8Decoder().convert(pub.payload.message!).trim();

      if (!mounted) return;
      setState(() => status = text);

      final id = device.id;
      if (id != null) {
        _home?.lastStatus[id] = text;
      }
    });
  }

  void _checkForExistingStatus() {
    if (!mounted) return;

    final lastStatus = _mqtt.getDeviceLastStatus(device);
    if (lastStatus != null && lastStatus.isNotEmpty) {
      setState(() {
        status = lastStatus;
      });

      final id = device.id;
      if (id != null) {
        _home?.lastStatus[id] = lastStatus;
      }
    }
  }

  @override
  void dispose() {
    _retainedCheckTimer?.cancel();
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }

  void _showDurationDialog() {
    int durationMinutes = 30;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Çalışma Süresi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (durationMinutes > 1) {
                            setState(() => durationMinutes -= 5);
                            if (durationMinutes < 1) {
                              durationMinutes = 1;
                            }
                          }
                        },
                      ),
                      Text(
                        "$durationMinutes dk",
                        style: const TextStyle(fontSize: 20),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (durationMinutes < 120) {
                            setState(() => durationMinutes += 5);
                            if (durationMinutes > 120) {
                              durationMinutes = 120;
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      final rec = device.topicRec?.trim();
                      if ((rec ?? '').isEmpty) return;
                      final payload = jsonEncode({
                        "command": "one_time",
                        "device": {"device_id": device.id},
                        "duration": durationMinutes * 60
                      });
                      _mqtt.publishMessage(rec!, payload);
                    },
                    child: const Text(
                      "Başlat",
                      style: TextStyle(
                          color: darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool offline = _mqtt.isDeviceOffline(device);
      final bool connected = _mqtt.isConnected.value;
      final bool isKnown = status.isNotEmpty;

      final bool disabled = offline || !connected || !isKnown;

      final bool isOn = status == "0";
      final double opacity = disabled ? 0.45 : 1.0;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: opacity,
            child: AbsorbPointer(
              absorbing: disabled,
              child: Switch(
                  activeColor: Colors.green,
                  value: isOn,
                  onChanged: (value) {
                    if (offline || !connected) return;

                    final rec = device.topicRec?.trim();
                    if ((rec ?? '').isEmpty) return;

                    if (value) {
                      _showDurationDialog();
                    } else {
                      final payload = jsonEncode({
                        "command": "cancel_watering",
                        "device": {"device_id": device.id}
                      });

                      _mqtt.publishMessage(rec!, payload);
                    }
                  }),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            offline
                ? ""
                : (!connected
                    ? "Bağlantı yok"
                    : (isKnown ? (isOn ? "Açık" : "Kapalı") : "Yükleniyor...")),
            style: textTheme(context).labelMedium?.copyWith(
                  fontWeight:
                      (connected && isOn) ? FontWeight.bold : FontWeight.normal,
                  color: offline
                      ? Colors.grey
                      : (isOn ? Colors.red : Colors.black),
                ),
          ),
        ],
      );
    });
  }
}
