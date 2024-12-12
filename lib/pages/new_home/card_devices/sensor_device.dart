import 'dart:convert';

import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

class SensorDevice extends StatefulWidget {
  final Device device;
  const SensorDevice({super.key, required this.device});

  @override
  State<SensorDevice> createState() => _SensorDeviceState();
}

class _SensorDeviceState extends State<SensorDevice> {
  late Device device;
  final MqttController _mqttController = Get.find<MqttController>();
  String status = "-";
  bool isSub = false;
  bool onAlarm = false;
  @override
  void initState() {
    super.initState();
    device = widget.device;
    _mqttController.subscribeToTopic(device.topicStat);

    _mqttController.onMessage((topic, message) {
      if (topic == device.topicStat) {
        if (message.contains("{")) {
          var result = json.decode(message);
          if (mounted) {
            setState(() {
              status = result["deger"].toString();
            });
            if (device.typeId == 1) {
              var deger = (result["deger"] is num)
                  ? (result["deger"] as num).toDouble()
                  : null;
              //var id = result["device_id"] as int?;
              if (deger != null &&
                  (device.normalMinValue != null ||
                      device.normalMaxValue != null)) {
                setState(() {
                  onAlarm = deger < device.normalMinValue! ||
                      deger > device.normalMaxValue!;
                });
              }
            }
          }
        }
      }
    });
    _mqttController.subListenerList.add((topic) {
      if (mounted) {
        setState(() {
          if (topic == device.topicStat) {
            isSub = true;
          }
        });
      }
    });
    var result = _mqttController.getSubscriptionTopicStatus(device.topicStat);
    if (result == MqttSubscriptionStatus.active) {
      if (mounted) {
        setState(() {
          isSub = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  device.typeId == 1
                      ? FontAwesomeIcons.temperatureHalf
                      : device.typeId == 2
                          ? FontAwesomeIcons.droplet
                          : FontAwesomeIcons.wind,
                  shadows: <Shadow>[
                    Shadow(
                      color: goldColor,
                      blurRadius: 15.0,
                    ),
                  ],
                  size: width(context) * 0.07,
                  color: Colors.white70,
                ),
                if (device.unit != null)
                  Text(
                    device.unit ?? "",
                    style: textTheme(context).titleLarge,
                  ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              status,
              style: textTheme(context).displaySmall,
            ),
            SizedBox(height: 20),
            Text(
              device.name,
              style: textTheme(context).titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
