import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:turkish/turkish.dart';

class BarrierDevice extends StatefulWidget {
  final Device device;
  const BarrierDevice({super.key, required this.device});

  @override
  State<BarrierDevice> createState() => _BarrierDeviceState();
}

class _BarrierDeviceState extends State<BarrierDevice> {
  late Device device;
  final MqttController _mqttController = Get.find<MqttController>();
  String status = "1";
  bool isSub = false;
  int openCount = 0;
  int closeCount = 0;
  int waitingCount = 0;

  @override
  void initState() {
    super.initState();
    device = widget.device;
    if (_mqttController.clientIsNull.value ||
        !_mqttController.isConnected.value) return;
    _mqttController.subscribeToTopic(device.topicStat);

    _mqttController.onMessage((topic, message) {
      if (topic == device.topicStat) {
        if (mounted) {
          setState(() {
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
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  FontAwesomeIcons.squareParking,
                  shadows: isSub
                      ? <Shadow>[
                          Shadow(
                            color: goldColor,
                            blurRadius: 15.0,
                          ),
                        ]
                      : null,
                  size: width(context) * 0.07,
                  color: Colors.white70,
                ),
                SizedBox(width: 0),
                SizedBox(width: 0),
              ],
            ),
            _switch2(),
            Text(
              status == "1"
                  ? "Kapalı"
                  : status == "2"
                      ? "Açılıyor"
                      : status == "3"
                          ? "Açık"
                          : status == "4"
                              ? "Kapanıyor"
                              : "",
              style: TextStyle(
                  color: status == "1" || status == "4"
                      ? Colors.red
                      : Colors.green),
            ),
            SizedBox(height: 5),
            Text(
              device.name.toTitleCaseTr(),
              style: textTheme(context).titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  _switch2() {
    return Card(
      elevation: 5,
      shape: CircleBorder(),
      child: InkWell(
        onTap: () {
          sendMessage();
        },
        borderRadius: BorderRadius.circular(30),
        child: CircularPercentIndicator(
          radius: 30,
          percent: status == "2"
              ? openCount / device.openingTime!
              : status == "4"
                  ? closeCount / device.closingTime!
                  : waitingCount.isOdd
                      ? 0
                      : 1,
          progressColor:
              status == "2" || status == "3" ? Colors.green : Colors.red,
          backgroundColor: Colors.white,
          center: Icon(
            FontAwesomeIcons.powerOff,
            color: status == "2" || status == "3" ? Colors.green : Colors.red,
            size: 25,
          ),
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
        backgroundColor: status == "2" || status == "3"
            ? goldColor.withOpacity(0.3)
            : goldColor.withOpacity(0.7),
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
          : Icon(
              FontAwesomeIcons.powerOff,
              color: Colors.red,
              size: 32.0,
            ),
    );
  }

  sendMessage() {
    if (_mqttController.isConnected.value) {
      if (device.typeId == 4) {
        _mqttController.publishMessage(device.topicRec!, "0");
      }
      if (device.typeId == 6 && device.rfCodes != null) {
        _mqttController.publishMessage(device.topicRec!, device.rfCodes![0]);
      }
    }
  }
}
