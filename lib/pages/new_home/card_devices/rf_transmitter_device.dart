import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

class RfTransmitterDevice extends StatefulWidget {
  final Device device;
  const RfTransmitterDevice({super.key, required this.device});

  @override
  State<RfTransmitterDevice> createState() => _RfTransmitterDeviceState();
}

class _RfTransmitterDeviceState extends State<RfTransmitterDevice> {
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
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  FontAwesomeIcons.eject,
                  shadows: isSub
                      ? <Shadow>[
                          Shadow(
                            color: Colors.indigo,
                            blurRadius: 15.0,
                          ),
                        ]
                      : null,
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
            _switch(),
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

  _switch() {
    return AnimatedToggleSwitch<bool>.dual(
      current: status == "2" || status == "3",
      first: false,
      second: true,
      spacing: 0.0,
      loading: status == "2" || status == "4",
      animationDuration: const Duration(milliseconds: 600),
      style: const ToggleStyle(
        borderColor: Colors.transparent,
        indicatorColor: Colors.white,
        backgroundColor: Colors.amber,
      ),
      customStyleBuilder: (context, local, global) => ToggleStyle(
        backgroundColor:
            status == "2" || status == "3" ? Colors.green : Colors.blue[400],
      ),
      height: width(context) * 0.12,
      loadingIconBuilder: (context, global) => CupertinoActivityIndicator(
          color: Color.lerp(Colors.blue, Colors.blue, global.spacing)),
      active: status == "1",
      onTap: (props) {
        sendMessage();
      },
      iconBuilder: (value) => value
          ? const Icon(
              FontAwesomeIcons.powerOff,
              color: Colors.green,
              size: 32.0,
            )
          : const Icon(
              FontAwesomeIcons.powerOff,
              color: Colors.red,
              size: 32.0,
            ),
    );
  }

  sendMessage() {
    if (_mqttController.isConnected.value && device.rfCodes != null) {
      _mqttController.publishMessage(device.topicRec!, device.rfCodes![0]);
    }
  }
}
