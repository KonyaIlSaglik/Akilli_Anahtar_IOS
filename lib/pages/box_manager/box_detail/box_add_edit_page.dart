import 'dart:convert';

import 'package:akilli_anahtar/controllers/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/device_management_controller.dart';
import 'package:akilli_anahtar/controllers/home_controller.dart';
import 'package:akilli_anahtar/controllers/mqtt_controller.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/models/nodemcu_info_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

class BoxAddEditPage extends StatefulWidget {
  const BoxAddEditPage({super.key});

  @override
  State<BoxAddEditPage> createState() => _BoxAddEditPageState();
}

class _BoxAddEditPageState extends State<BoxAddEditPage> {
  BoxManagementController boxManagementController = Get.find();
  late DeviceManagementController deviceManagementController = Get.find();
  MqttController mqttController = Get.find();
  HomeController homeController = Get.find();
  final _formKey = GlobalKey<FormState>();
  late String boxName;
  late String chipId;
  late String topicRec;
  late String topicRes;
  late bool active;
  late String version;
  late int organisationId;
  late String restartTimeOut;

  @override
  void initState() {
    super.initState();

    boxName = "";
    chipId = "";
    topicRec = "";
    topicRes = "";
    active = true;
    version = "";
    organisationId = 0;
    restartTimeOut = "";

    if (boxManagementController.selectedBox.value.id > 0) {
      boxName = boxManagementController.selectedBox.value.name;
      chipId = boxManagementController.selectedBox.value.chipId.toString();
      topicRec = boxManagementController.selectedBox.value.topicRec;
      topicRes = boxManagementController.selectedBox.value.topicRes;
      active = boxManagementController.selectedBox.value.active == 1;
      version = boxManagementController.selectedBox.value.version;
      organisationId = boxManagementController.selectedBox.value.organisationId;
      restartTimeOut =
          (boxManagementController.selectedBox.value.restartTimeout ~/ 60000)
              .toString();
      if (mqttController.getSubscriptionTopicStatus(
              boxManagementController.selectedBox.value.topicRec) ==
          MqttSubscriptionStatus.active) {
        print("${boxManagementController.selectedBox.value.topicRec} active");
        boxManagementController.selectedBox.value.isSub = true;
        setState(() {});
      } else {
        mqttController.subListenerList.add(
          (topic) {
            if (topic == boxManagementController.selectedBox.value.topicRes) {
              boxManagementController.selectedBox.value.isSub = true;
              if (mounted) {
                setState(() {});
              }
            }
          },
        );
        mqttController.subscribeToTopic(
            boxManagementController.selectedBox.value.topicRes);
      }
      mqttController.publishMessage(
          boxManagementController.selectedBox.value.topicRec, "getinfo");
      mqttController.onMessage(
        (topic, message) {
          if (topic == boxManagementController.selectedBox.value.topicRes) {
            if (message == "boxConnected") {
              boxManagementController.selectedBox.value.isSub = true;
              boxManagementController.selectedBox.value.upgrading = false;
            }
            if (message == "upgrading") {
              boxManagementController.selectedBox.value.upgrading = true;
            }
            try {
              var infoModel = NodemcuInfoModel();
              infoModel = NodemcuInfoModel.fromJson(message);
              if (infoModel.chipId.isNotEmpty) {
                boxManagementController.selectedBox.value.apEnable =
                    infoModel.apEnable;
              }
            } catch (e) {
              print(e);
            }
            if (mounted) {
              setState(() {});
            }
          }
        },
      );
    }
  }

  bool isJson(String data) {
    try {
      json.decode(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        title: Text(boxManagementController.selectedBox.value.id == 0
            ? 'Kutu Ekle'
            : 'Kutu Düzenle'),
      ),
      body: Obx(
        () {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<Organisation>(
                      decoration: InputDecoration(
                        labelText: "Kurum",
                      ),
                      value: organisationId > 0
                          ? homeController.organisations.singleWhere(
                              (o) => o.id == organisationId,
                            )
                          : homeController.organisations.first,
                      items: homeController.organisations.map(
                        (organisation) {
                          return DropdownMenuItem<Organisation>(
                            value: organisation,
                            child: Text(organisation.name),
                          );
                        },
                      ).toList(),
                      onChanged: (value) => organisationId = value?.id ?? 0,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Kutu Adı'),
                      initialValue: boxName,
                      onChanged: (value) => boxName = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a boxname';
                        }
                        var existsBox = boxManagementController.boxes
                            .firstWhereOrNull((u) => u.name == value);
                        if (existsBox != null) {
                          return 'Kutu adı daha önce kullanılmış';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        SizedBox(
                          width: width * 0.40,
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Chip Id'),
                            initialValue: chipId,
                            keyboardType: TextInputType.number,
                            onChanged: (value) => chipId = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an id';
                              }
                              var existsBox = boxManagementController.boxes
                                  .firstWhereOrNull(
                                      (u) => u.chipId.toString() == value);
                              if (existsBox != null) {
                                return 'ID daha önce kullanılmış';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          width: width * 0.40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("Kutu Aktif"),
                              Checkbox(
                                value: active,
                                onChanged: (value) {
                                  setState(() {
                                    active = value ?? false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Otomatik Yeniden Başlatma Süresi (dk)'),
                      initialValue: restartTimeOut,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => restartTimeOut = value,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Topic Rec'),
                      initialValue: topicRec,
                      enabled: false,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Topic Res'),
                      initialValue: topicRes,
                      enabled: false,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      child: Text("Kaydet"),
                      onPressed: () {
                        //
                      },
                    ),
                    if (boxManagementController.selectedBox.value.id > 0)
                      Column(
                        children: [
                          Divider(),
                          ListTile(
                            title: Text(boxManagementController
                                    .selectedBox.value.apEnable
                                ? "AP Mod Açık"
                                : "AP Mod Kapalı"),
                            trailing: ElevatedButton(
                              child: Text(boxManagementController
                                      .selectedBox.value.apEnable
                                  ? "Kapat"
                                  : "Aç"),
                              onPressed: () {
                                boxManagementController
                                        .selectedBox.value.apEnable
                                    ? mqttController.publishMessage(
                                        boxManagementController
                                            .selectedBox.value.topicRec,
                                        "apdisable")
                                    : mqttController.publishMessage(
                                        boxManagementController
                                            .selectedBox.value.topicRec,
                                        "apenable");
                              },
                            ),
                            onTap: () {},
                          ),
                          Divider(),
                          ListTile(
                            title: Text("Yeniden Başlat"),
                            trailing: IconButton(
                              icon: Icon(
                                FontAwesomeIcons.rotate,
                                color: Colors.orange,
                              ),
                              onPressed: () {
                                mqttController.publishMessage(
                                    boxManagementController
                                        .selectedBox.value.topicRec,
                                    "reboot");
                              },
                            ),
                          ),
                          Divider(),
                          ListTile(
                            title: Text(
                                "V:${boxManagementController.selectedBox.value.version}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (boxManagementController
                                        .selectedBox.value.isOld ==
                                    -1)
                                  Text(
                                    "Yeni Version: ${boxManagementController.newVersion.value.version}",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                if (boxManagementController
                                        .selectedBox.value.isOld ==
                                    0)
                                  Text(
                                    "Sürüm Güncel",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                if (boxManagementController
                                        .selectedBox.value.isOld ==
                                    1)
                                  Text(
                                    "Test Sürüm",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (boxManagementController
                                            .selectedBox.value.isOld ==
                                        -1 &&
                                    boxManagementController
                                        .selectedBox.value.isSub)
                                  IconButton(
                                    icon: Icon(
                                      Icons.upload_outlined,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      mqttController.publishMessage(
                                          boxManagementController
                                              .selectedBox.value.topicRec,
                                          "doUpgrade");
                                    },
                                  ),
                                if (boxManagementController
                                        .selectedBox.value.upgrading &&
                                    boxManagementController
                                        .selectedBox.value.isSub)
                                  RotatedBox(
                                    quarterTurns: 2,
                                    child: Icon(
                                      FontAwesomeIcons.clockRotateLeft,
                                      color: Colors.blue,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
