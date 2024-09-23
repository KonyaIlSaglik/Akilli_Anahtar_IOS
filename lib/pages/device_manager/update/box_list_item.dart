import 'dart:convert';

import 'package:akilli_anahtar/controllers/mqtt_controller.dart';
import 'package:akilli_anahtar/controllers/update_controller.dart';
import 'package:akilli_anahtar/models/nodemcu_info_model.dart';
import 'package:akilli_anahtar/utils/constants.dart';
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
            print(message);
            updateController.boxList[i].infoModel =
                NodemcuInfoModel.fromJson(message);
            var jsonData = json.decode(message);
            if (jsonData != null && jsonData["version"] != null) {
              var info = NodemcuInfoModel.fromJson(message);
              updateController.boxList[i].box.version = info.version;
              var bv = updateController.boxList[i].box.version;
              var nv = updateController.newVersion.value;
              if (nv.version.isNotEmpty) {
                var bv1 = int.tryParse(bv.split(".")[0]) ?? 0;
                var nv1 = int.tryParse(nv.version.split(".")[0]) ?? 0;
                if (bv1 < nv1) {
                  updateController.boxList[i].isOld = true;
                } else {
                  var bv2 = int.tryParse(bv.split(".")[1]) ?? 0;
                  var nv2 = int.tryParse(nv.version.split(".")[1]) ?? 0;
                  if (bv2 < nv2) {
                    updateController.boxList[i].isOld = true;
                  } else {
                    updateController.boxList[i].isOld = false;
                  }
                }
              }
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            updateController.boxList[i].upgrading
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
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                if (updateController.boxList[i].infoModel != null) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      var infoModel = updateController.boxList[i].infoModel;
                      return SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.80, // Adjust height as needed
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Title for the modal
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      "Cihaz Bilgileri",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Closes the modal
                                    },
                                  ),
                                ],
                              ),
                              Divider(), // Optional divider for separation
                              Expanded(
                                child: ListView(
                                  children: [
                                    ListTile(
                                      title: Text("Cihaz Adı:"),
                                      trailing: Text(
                                          infoModel!.boxWithDevices!.box!.name),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  infoSnackbar("Uyarı", "Cihaz Bilgisi bulunamadı");
                }
              },
            ),
          ],
        ),
      );
    });
  }

  void checkUpdate() async {
    //await updateController.checkNewVersion();
    mqttController.publishMessage(
        updateController.boxList[i].box.topicRec, "getinfo");
  }
}
