import 'package:akilli_anahtar/controllers/mqtt_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_text_scroll.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:turkish/turkish.dart';

class RfCommandItem6 extends StatefulWidget {
  final Device device;
  const RfCommandItem6({super.key, required this.device});

  @override
  State<RfCommandItem6> createState() => _RfCommandItem6State();
}

class _RfCommandItem6State extends State<RfCommandItem6>
    with AutomaticKeepAliveClientMixin {
  late Device device;
  final MqttController _mqttController = Get.find<MqttController>();

  bool isSub = false;
  String status = "KAPALI";
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
    super.build(context);
    return InkWell(
      onTap: () {
        if (_mqttController.isConnected.value) {
          _mqttController.publishMessage(device.topicRec!, device.rfCodes![0]);
        }
      },
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                goldColor.withOpacity(1),
                goldColor.withOpacity(1),
              ]),
              borderRadius: BorderRadius.circular(10)),
          child: body(),
        ),
      ),
    );
  }

  body() {
    var height = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: height * 0.035,
          child: Card(
            elevation: 0,
            color: !isSub ? Colors.grey : Colors.blue,
            child: Center(
              child: Text(
                status == "0"
                    ? "AÇIK"
                    : status == "1"
                        ? "KAPALI"
                        : status,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: height * 0.06,
          child: Center(
              child: ImageIcon(
            Image.asset("assets/rf_control.png").image,
            size: (Theme.of(context).iconTheme.size ?? 28) * 2,
            color: Colors.white,
          )),
        ),
        Expanded(
          flex: 20,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 5),
            child: CustomTextScroll(
              text: device.name.toUpperCaseTr(),
            ),
          ),
        ),
        Expanded(
          flex: 20,
          child: Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 0),
            child: CustomTextScroll(
              text: "",
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
