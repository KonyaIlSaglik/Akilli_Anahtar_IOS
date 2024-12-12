import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

class GardenDevice extends StatefulWidget {
  final Device device;
  const GardenDevice({super.key, required this.device});

  @override
  State<GardenDevice> createState() => _GardenDeviceState();
}

class _GardenDeviceState extends State<GardenDevice> {
  late Device device;
  final MqttController _mqttController = Get.find<MqttController>();
  String status = "1";
  bool isSub = false;
  @override
  void initState() {
    super.initState();
    device = widget.device;
    _mqttController.subscribeToTopic(device.topicStat);

    _mqttController.onMessage((topic, message) {
      if (topic == device.topicStat) {
        if (mounted) {
          setState(() {
            status = message;
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
                  status == "0"
                      ? FontAwesomeIcons.faucetDrip
                      : FontAwesomeIcons.faucet,
                  shadows: isSub
                      ? <Shadow>[
                          Shadow(
                            color: status == "0" ? Colors.blue : Colors.black,
                            blurRadius: 15.0,
                          ),
                        ]
                      : null,
                  size: width(context) * 0.07,
                  color: Colors.white70,
                ),
                InkWell(
                  child: Icon(
                    FontAwesomeIcons.clock,
                    color: Colors.green,
                    shadows: <Shadow>[
                      Shadow(
                        color: Colors.green,
                        blurRadius: 15.0,
                      ),
                    ],
                  ),
                  onTap: () {
                    //
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            _switch(),
            SizedBox(height: 20),
            Text(
              device.name,
              style: textTheme(context).titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  _switch() {
    return AnimatedToggleSwitch<bool>.dual(
      current: status == "0",
      first: false,
      second: true,
      spacing: 0.0,
      loading: false,
      animationDuration: const Duration(milliseconds: 600),
      style: const ToggleStyle(
        borderColor: Colors.transparent,
        indicatorColor: Colors.white,
        backgroundColor: Colors.amber,
      ),
      customStyleBuilder: (context, local, global) => ToggleStyle(
        backgroundColor: status == "0"
            ? goldColor.withOpacity(0.3)
            : goldColor.withOpacity(0.7),
      ),
      height: width(context) * 0.12,
      loadingIconBuilder: (context, global) => CupertinoActivityIndicator(
          color: Color.lerp(Colors.blue, Colors.blue, global.spacing)),
      active: true,
      onTap: (props) {
        sendMessage();
      },
      iconBuilder: (value) => value
          ? const Icon(
              FontAwesomeIcons.powerOff,
              color: Colors.green,
              size: 32.0,
            )
          : Icon(
              FontAwesomeIcons.powerOff,
              color: Colors.red[400],
              size: 32.0,
            ),
    );
  }

  sendMessage() {
    if (_mqttController.isConnected.value) {
      _mqttController.publishMessage(
          device.topicRec!, status == "0" ? "1" : "0");
    }
  }
}
