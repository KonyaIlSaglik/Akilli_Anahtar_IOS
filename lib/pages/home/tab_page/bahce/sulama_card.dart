import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/pages/home/tab_page/bahce/zamanlama_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

class BahceSulamaCard extends StatefulWidget {
  final Device device;
  const BahceSulamaCard({
    super.key,
    required this.device,
  });

  @override
  State<BahceSulamaCard> createState() => _BahceSulamaCardState();
}

class _BahceSulamaCardState extends State<BahceSulamaCard> {
  late Device device;
  final MqttController _mqttController = Get.find<MqttController>();
  bool isSub = false;

  bool _checked = false;

  @override
  void initState() {
    super.initState();

    device = widget.device;
    _mqttController.subscribeToTopic(device.topicStat);
    _mqttController.onMessage((topic, message) {
      if (topic == device.topicStat) {
        if (mounted) {
          setState(() {
            _checked = message == "0" ? true : false;
          });
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [goldColor.withOpacity(1), goldColor.withOpacity(1)]),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          _checked
                              ? FontAwesomeIcons.faucetDrip
                              : FontAwesomeIcons.faucet,
                          color: _checked ? Colors.blue : Colors.white,
                        ),
                      ),
                      Text(
                        device.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .fontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "En Son: ${DateFormat("dd MMMM yyyy HH:mm", "tr_TR").format(DateTime.now())}",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _checked
                        ? FontAwesomeIcons.toggleOn
                        : FontAwesomeIcons.toggleOff,
                    color: _checked ? Colors.blue : Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _mqttController.publishMessage(
                        device.topicRec!,
                        _checked ? "1" : "0",
                      );
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.clock,
                    color: _checked ? Colors.blue : Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            ZamanlamaPage(hat: device.name),
                      ),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
