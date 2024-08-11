import 'package:akilli_anahtar/controllers/mqtt_controller.dart';
import 'package:akilli_anahtar/models/control_device_model.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:turkish/turkish.dart';

class KapiItemActive extends StatefulWidget {
  final ControlDeviceModel device;
  const KapiItemActive({Key? key, required this.device}) : super(key: key);

  @override
  State<KapiItemActive> createState() => _KapiItemActiveState();
}

class _KapiItemActiveState extends State<KapiItemActive>
    with AutomaticKeepAliveClientMixin {
  late ControlDeviceModel device;
  final MqttController _mqttController = Get.find<MqttController>();
  bool isSub = false;
  String status = "KAPALI";
  @override
  void initState() {
    super.initState();
    device = widget.device;
    _mqttController.subscribeToTopic(device.topicStat!);
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
    return FocusDetector(
      child: InkWell(
        onTap: () {
          if (_mqttController.isConnected.value) {
            if (device.deviceTypeId == 4) {
              _mqttController.publishMessage(device.topicRec!, "0");
            }
            if (device.deviceTypeId == 5) {
              _mqttController.publishMessage(
                  device.topicRec!, status == "1" ? "0" : "1");
            }
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
            color: !isSub
                ? Colors.grey
                : device.deviceTypeId == 4
                    ? status == "AÇILIYOR"
                        ? Colors.yellow
                        : status == "AÇIK"
                            ? Colors.green[400]
                            : status == "KAPANIYOR"
                                ? Colors.yellow
                                : Colors.red
                    : device.deviceTypeId == 5
                        ? status == "1"
                            ? Colors.green
                            : Colors.red
                        : Colors.black,
            child: Center(
              child: Text(
                status == "1"
                    ? "AÇIK"
                    : status == "0"
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
            child: device.deviceTypeId == 4
                ? ImageIcon(
                    Image.asset("assets/barrier.png").image,
                    size: (Theme.of(context).iconTheme.size ?? 28) * 2,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.light_mode_outlined,
                    size: (Theme.of(context).iconTheme.size ?? 28) * 1.5,
                    color: Colors.white,
                  ),
          ),
        ),
        Expanded(
          flex: 20,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 5),
            child: TextScroll(
              device.name!.toUpperCaseTr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 20,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5),
                child: Text(""),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
