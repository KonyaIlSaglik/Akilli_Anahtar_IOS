import 'package:akilli_anahtar/controllers/admin/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/bm_box_dto.dart';
import 'package:akilli_anahtar/models/nodemcu_info_model.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

class BoxAddEditControl extends StatefulWidget {
  final BmBoxDto box;
  const BoxAddEditControl({super.key, required this.box});

  @override
  State<BoxAddEditControl> createState() => _BoxAddEditControlState();
}

class _BoxAddEditControlState extends State<BoxAddEditControl> {
  BoxManagementController boxManagementController = Get.find();
  MqttController mqttController = Get.find();

  late BmBoxDto box = widget.box;

  String apSatus = "";
  bool apChanging = false;
  bool restarting = false;
  String version = "-";
  bool upgrading = false;
  bool disable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  init() {
    if (mqttController.getSubscriptionTopicStatus(box.topicRec) ==
        MqttSubscriptionStatus.doesNotExist) {
      mqttController.subscribeToTopic(box.topicRes!);
      mqttController.subListenerList.add(
        (topic) {
          if (topic == box.topicRes) {}
        },
      );
    }
    mqttController.publishMessage(box.topicRec!, "getinfo");

    mqttController.onMessage(
      (topic, message) {
        if (topic == box.topicRes) {
          if (message == "boxConnected") {
            setState(() {
              upgrading = false;
              restarting = false;
            });
            mqttController.publishMessage(box.topicRec!, "getinfo");
          } else if (message == "restarting") {
            setState(() {
              restarting = true;
            });
          } else if (message == "upgrading") {
            setState(() {
              upgrading = true;
            });
          } else if (message == "ap-1") {
            setState(() {
              apSatus = "1";
              apChanging = true;
            });
          } else if (message == "ap-3") {
            setState(() {
              apSatus = "3";
              apChanging = true;
            });
          } else if (message.contains("{")) {
            try {
              var infoModel = NodemcuInfoModel();
              infoModel = NodemcuInfoModel.fromJson(message);
              if (infoModel.chip.isNotEmpty) {
                setState(() {
                  apSatus = infoModel.ap ? "2" : "0";
                  apChanging = false;
                  version = infoModel.ver;
                });
              }
            } catch (e) {
              print(e);
            }
          }
          if (mounted) {
            setState(() {
              disable = restarting || apChanging || upgrading;
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text("Cihaz Durum"),
          trailing: TextButton(
            onPressed: () {
              mqttController.publishMessage(box.topicRec!, "getinfo");
            },
            child: Text("Sorgula"),
          ),
        ),
        Divider(),
        Visibility(
          visible: apSatus.isNotEmpty,
          child: Column(
            children: [
              ListTile(
                title: Text("Yeniden Başlat"),
                subtitle: restarting ? Text("Yeniden başlatılıyor...") : null,
                trailing: restarting
                    ? CupertinoActivityIndicator(color: goldColor)
                    : IconButton(
                        icon: Icon(
                          FontAwesomeIcons.rotate,
                          color: apSatus.isEmpty ? Colors.grey : goldColor,
                        ),
                        onPressed: disable
                            ? null
                            : () {
                                mqttController.publishMessage(
                                    box.topicRec!, "restart");
                              },
                      ),
              ),
              Divider(),
              ListTile(
                title: Text("AP Mod"),
                subtitle: apSatus.isEmpty
                    ? null
                    : Text(
                        apSatus == "0"
                            ? "Kapalı"
                            : apSatus == "1"
                                ? "Açılıyor..."
                                : apSatus == "3"
                                    ? "Kapatılıyor..."
                                    : "Açık",
                      ),
                trailing: apChanging
                    ? CupertinoActivityIndicator(color: goldColor)
                    : IconButton(
                        onPressed: apSatus.isNotEmpty
                            ? disable
                                ? null
                                : () {
                                    mqttController.publishMessage(
                                        box.topicRec!,
                                        apSatus == "0"
                                            ? "apenable"
                                            : "apdisable");
                                  }
                            : null,
                        icon: Text(
                            apSatus.isEmpty
                                ? "Bilinmiyor"
                                : apSatus == "0"
                                    ? "Aç"
                                    : "Kapat",
                            style: TextStyle(
                                color:
                                    apSatus.isEmpty ? Colors.grey : goldColor)),
                      ),
              ),
              Divider(),
              ListTile(
                title: Text("V: $version"),
                subtitle: upgrading ? Text("Güncelleniyor...") : null,
                trailing: apSatus.isEmpty
                    ? TextButton(
                        onPressed: null,
                        child: Text("Bilinmiyor"),
                      )
                    : boxManagementController.versionControl(version) == -1
                        ? !upgrading
                            ? IconButton(
                                icon: Icon(
                                  Icons.upload_outlined,
                                  color: Colors.red,
                                ),
                                onPressed: disable
                                    ? null
                                    : () {
                                        mqttController.publishMessage(
                                            box.topicRec!, "upgrade");
                                      },
                              )
                            : CupertinoActivityIndicator(color: goldColor)
                        : TextButton(
                            onPressed: null,
                            child: Text("Güncel"),
                          ),
              ),
              Divider(),
              ListTile(
                title: Text("Wi-fi Ayarları Sıfırla"),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                  onPressed: disable
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text(
                                    "Wi-fi ayarları sıfırlanacak ve cihaz SmartConnect moduna geçecektir."),
                                title: Text("Dikkat"),
                                actions: [
                                  TextButton(
                                    child: Text("Vazgeç"),
                                    onPressed: () {
                                      Get.back();
                                    },
                                  ),
                                  TextButton(
                                    child: Text("Sıfırla"),
                                    onPressed: () {
                                      mqttController.publishMessage(
                                          box.topicRec!, "wifireset");
                                      Get.back();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ],
    );
  }
}
