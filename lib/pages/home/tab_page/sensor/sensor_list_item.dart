import 'dart:convert';

import 'package:akilli_anahtar/controllers/mqtt_controller.dart';
import 'package:akilli_anahtar/models/sensor_device_model.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

class SensorListItem extends StatefulWidget {
  final SensorDeviceModel sensor;
  const SensorListItem({
    Key? key,
    required this.sensor,
  }) : super(key: key);

  @override
  State<SensorListItem> createState() => _SensorListItemState();
}

class _SensorListItemState extends State<SensorListItem> {
  late SensorDeviceModel sensor;
  final MqttController _mqttController = Get.find<MqttController>();
  String status = "-";
  bool isSub = false;
  bool onAlarm = false;
  @override
  void initState() {
    super.initState();
    sensor = widget.sensor;
    _mqttController.subscribeToTopic(sensor.topicStat!);

    _mqttController.onMessage((topic, message) {
      if (topic == sensor.topicStat) {
        print(message);
        var result = json.decode(message);
        if (mounted) {
          setState(() {
            status = result["deger"].toString();
          });
          if (sensor.deviceTypeId == 1) {
            var deger = (result["deger"] is num)
                ? (result["deger"] as num).toDouble()
                : null;
            //var id = result["sensor_id"] as int?;
            if (deger != null &&
                (sensor.valueRangeMin != null ||
                    sensor.valueRangeMax != null)) {
              setState(() {
                onAlarm = deger < sensor.valueRangeMin! ||
                    deger > sensor.valueRangeMax!;
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
            print('Subscribed to $topic');
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
                  // Text(
                  //   kurum!,
                  //   style: TextStyle(color: Colors.white),
                  // ),
                  Text(
                    sensor.valueRangeId != null && sensor.valueRangeId! > 0
                        ? "${sensor.valueRangeMin} - ${sensor.valueRangeMax}"
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
