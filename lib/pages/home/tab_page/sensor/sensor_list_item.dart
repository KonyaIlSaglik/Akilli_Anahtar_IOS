import 'dart:convert';

import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

class SensorListItem extends StatefulWidget {
  final Device sensor;
  const SensorListItem({
    super.key,
    required this.sensor,
  });

  @override
  State<SensorListItem> createState() => _SensorListItemState();
}

class _SensorListItemState extends State<SensorListItem> {
  late Device sensor;
  final MqttController _mqttController = Get.find<MqttController>();
  String status = "-";
  bool isSub = false;
  bool onAlarm = false;
  @override
  void initState() {
    super.initState();
    sensor = widget.sensor;
    _mqttController.subscribeToTopic(sensor.topicStat);

    _mqttController.onMessage((topic, message) {
      if (topic == sensor.topicStat) {
        var result = json.decode(message);
        if (mounted) {
          setState(() {
            status = result["deger"].toString();
          });
          if (sensor.typeId == 1) {
            var deger = (result["deger"] is num)
                ? (result["deger"] as num).toDouble()
                : null;
            //var id = result["sensor_id"] as int?;
            if (deger != null &&
                (sensor.normalMinValue != null ||
                    sensor.normalMaxValue != null)) {
              setState(() {
                onAlarm = deger < sensor.normalMinValue! ||
                    deger > sensor.normalMaxValue!;
              });
            }
          }
        }
      }
    });
    _mqttController.subListenerList.add((topic) {
      if (mounted) {
        setState(() {
          if (topic == sensor.topicStat) {
            isSub = true;
          }
        });
      }
    });
    var result = _mqttController.getSubscriptionTopicStatus(sensor.topicStat);
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
              color: !isSub || status == "-"
                  ? Colors.grey
                  : onAlarm
                      ? Colors.red
                      : Colors.green,
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
                    sensor.name!,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  Text(
                    sensor.normalValueRangeId! > 0
                        ? "${sensor.normalMinValue} - ${sensor.normalMaxValue}"
                        : "-",
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
                    "$status ${sensor.unit}",
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
