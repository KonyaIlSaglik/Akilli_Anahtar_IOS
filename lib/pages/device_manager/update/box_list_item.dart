import 'package:akilli_anahtar/controllers/mqtt_controller.dart';
import 'package:akilli_anahtar/controllers/update_controller.dart';
import 'package:akilli_anahtar/models/nodemcu_info_model.dart';
import 'package:akilli_anahtar/pages/device_manager/update/new_version_item.dart';
import 'package:akilli_anahtar/pages/device_manager/update/old_version_item.dart';
import 'package:akilli_anahtar/pages/device_manager/update/passive_item.dart';
import 'package:flutter/material.dart';

import 'package:akilli_anahtar/entities/box.dart';
import 'package:get/get.dart';

class BoxListItem extends StatefulWidget {
  final Box box;
  const BoxListItem({
    Key? key,
    required this.box,
  }) : super(key: key);

  @override
  State<BoxListItem> createState() => _BoxListItemState();
}

class _BoxListItemState extends State<BoxListItem> {
  final MqttController _mqttController = Get.put(MqttController());
  UpdateController updateController = Get.find<UpdateController>();
  late Box box;
  Widget? body;
  bool upgrading = false;
  NodemcuInfoModel info = NodemcuInfoModel();
  @override
  void initState() {
    super.initState();
    box = widget.box;
    body = PassiveItem(
      box: box,
      onPressed: () {
        _mqttController.subscribeToTopic(box.topicRes);
      },
    );
    _mqttController.subscribeToTopic(box.topicRes);
    _mqttController.publishMessage(box.topicRec, "getinfo");
    _mqttController.onMessage((topic, message) {
      if (topic == box.topicRes) {
        if (message.isNotEmpty) {
          if (message == "boxConnected") {
            setState(() {
              upgrading = false;
            });
            _mqttController.publishMessage(box.topicRec, "getinfo");
          } else {
            if (mounted) {
              setState(() {
                info = NodemcuInfoModel.fromJson(message);
                box.version = info.version;
                if (info.version.compareTo(updateController.newVersion.value) <
                    0) {
                  body = OldVersionItem(
                    box: box,
                    upgrading: upgrading,
                    onPressed: () {
                      setState(() {
                        upgrading = true;
                      });
                      _mqttController.publishMessage(box.topicRec, "doUpgrade");
                    },
                  );
                } else {
                  body = NewVersionItem(box: box);
                }
              });
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return body ?? Center(child: CircularProgressIndicator());
  }
}
