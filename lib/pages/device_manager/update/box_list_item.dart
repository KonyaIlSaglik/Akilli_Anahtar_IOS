import 'dart:convert';

import 'package:akilli_anahtar/controllers/mqtt_controller.dart';
import 'package:akilli_anahtar/controllers/update_controller.dart';
import 'package:akilli_anahtar/models/nodemcu_info_model.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class BoxListItem extends StatefulWidget {
  final int index;
  const BoxListItem({
    Key? key,
    this.index = 0,
  }) : super(key: key);

  @override
  State<BoxListItem> createState() => _BoxListItemState();
}

class _BoxListItemState extends State<BoxListItem> {
  MqttController mqttController = Get.find();
  UpdateController updateController = Get.find();
  late int i;
  @override
  void initState() {
    super.initState();
    i = widget.index;
    mqttController.subscribeToTopic(updateController.boxList[i].box.topicRes);
    mqttController.publishMessage(
        updateController.boxList[i].box.topicRec, "getinfo");
    mqttController.onMessage((topic, message) {
      if (topic == updateController.boxList[i].box.topicRes) {
        if (message.isNotEmpty) {
          if (message == "boxConnected") {
            updateController.boxList[i].isSub = true;
            updateController.boxList[i].upgrading = false;
            mqttController.publishMessage(
                updateController.boxList[i].box.topicRec, "getinfo");
          }
          if (isJson(message)) {
            updateController.boxList[i].isSub = true;
            var jsonData = json.decode(message);
            if (jsonData != null && jsonData["version"] != null) {
              var info = NodemcuInfoModel.fromJson(message);
              updateController.boxList[i].box.version = info.version;
              double bv =
                  double.tryParse(updateController.boxList[i].box.version) ?? 0;
              double nv =
                  double.tryParse(updateController.newVersion.value) ?? 0;
              updateController.boxList[i].isOld = bv < nv;
            }
          }
        } else {
          updateController.boxList[i].isSub = false;
        }
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  bool isJson(String message) {
    try {
      json.decode(message);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListTile(
        leading: Icon(
          FontAwesomeIcons.hardDrive,
          color: updateController.boxList[i].isSub ? Colors.blue : Colors.grey,
          size: 30,
        ),
        title: Text(updateController.boxList[i].box.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Version: ${updateController.boxList[i].box.version}"),
            updateController.boxList[i].upgrading
                ? Text(
                    "Güncelleniyor...",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  )
                : updateController.boxList[i].isSub
                    ? updateController.boxList[i].isOld
                        ? Text(
                            "(Yeni sürüm mevcut: ${updateController.newVersion})",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          )
                        : Text(
                            "(Sürüm Güncel)",
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          )
                    : Text("Bağlı değil"),
          ],
        ),
        trailing: updateController.boxList[i].upgrading
            ? IconButton(
                icon: Icon(
                  Icons.update,
                  color: Colors.blue,
                ),
                onPressed: () {
                  //
                },
              )
            : updateController.boxList[i].isSub
                ? updateController.boxList[i].isOld
                    ? IconButton(
                        icon: Icon(
                          Icons.upload_outlined,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          updateController.boxList[i].upgrading = true;
                          mqttController.publishMessage(
                              updateController.boxList[i].box.topicRec,
                              "doUpgrade");
                          setState(() {});
                        },
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.done,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          //
                        },
                      )
                : IconButton(
                    onPressed: () {
                      checkUpdate();
                    },
                    icon: Icon(
                      Icons.refresh,
                    ),
                  ),
      );
    });
  }

  void checkUpdate() async {
    await updateController.checkNewVersion();
    mqttController.publishMessage(
        updateController.boxList[i].box.topicRec, "getinfo");
  }
}
