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

  @override
  void initState() {
    super.initState();
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
          if (mounted) {
            setState(() {
              if (message == "boxConnected") {
                upgrading = false;
                restarting = false;
                mqttController.publishMessage(box.topicRec!, "getinfo");
              }
              if (message == "restarting") {
                restarting = true;
              }
              if (message == "upgrading") {
                upgrading = true;
              }
              if (message == "ap-1") {
                apSatus = "1";
                apChanging = true;
              }
              if (message == "ap-3") {
                apSatus = "3";
                apChanging = true;
              }
            });
          }
          try {
            var infoModel = NodemcuInfoModel();
            infoModel = NodemcuInfoModel.fromJson(message);
            if (infoModel.chipId.isNotEmpty) {
              apSatus = infoModel.apEnable ? "2" : "0";
              apChanging = false;
              version = infoModel.version;
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
                        onPressed: restarting
                            ? null
                            : () {
                                mqttController.publishMessage(
                                    box.topicRec!, "reboot");
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
                            ? () {
                                mqttController.publishMessage(box.topicRec!,
                                    apSatus == "0" ? "apenable" : "apdisable");
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
                                onPressed: () {
                                  mqttController.publishMessage(
                                      box.topicRec!, "doUpgrade");
                                },
                              )
                            : CupertinoActivityIndicator(color: goldColor)
                        : TextButton(
                            onPressed: null,
                            child: Text("Güncel"),
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
