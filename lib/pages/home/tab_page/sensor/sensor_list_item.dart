import 'dart:convert';

import 'package:akilli_anahtar/controllers/mqtt_controller.dart';
import 'package:akilli_anahtar/models/sensor_device_model.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

class SensorListItem extends StatefulWidget {
  final SensorDeviceModel device;
  const SensorListItem({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  State<SensorListItem> createState() => _SensorListItemState();
}

class _SensorListItemState extends State<SensorListItem> {
  late SensorDeviceModel device;
  final MqttController _mqttController = Get.find<MqttController>();
  String status = "";
  bool isSub = false;
  @override
  void initState() {
    super.initState();
    device = widget.device;
    _mqttController.subscribeToTopic(device.topicStat!, (message) {
      var result = json.decode(message);
      if (mounted) {
        setState(() {
          status = result["deger"].toString();
        });
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
    return Center(
      child: Card(
        color: goldColor,
        child: Row(
          children: [
            Card(
              color: isSub ? Colors.green : Colors.grey,
              child: SizedBox(
                width: 15,
                height: 100,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    device.name!,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  // Text(
                  //   kurum!,
                  //   style: TextStyle(color: Colors.white),
                  // ),
                  Text(
                    "Durum: ",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$status ${device.unit}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
