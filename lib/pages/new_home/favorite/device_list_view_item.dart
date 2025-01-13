import 'dart:convert';

import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:turkish/turkish.dart';

class DeviceListViewItem extends StatefulWidget {
  final HomeDeviceDto device;

  const DeviceListViewItem({super.key, required this.device});

  @override
  State<DeviceListViewItem> createState() => _DeviceListViewItemState();
}

class _DeviceListViewItemState extends State<DeviceListViewItem> {
  final MqttController _mqttController = Get.find<MqttController>();
  late HomeDeviceDto device;
  String status = "";
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
            if (device.typeId == 1 ||
                device.typeId == 2 ||
                device.typeId == 3) {
              if (message.contains("{")) {
                final dynamic data;
                device.typeId! < 3
                    ? data = json.decode(message)["deger"] as double
                    : data = json.decode(message)["deger"] as int;
                status = data.toString();
              }
            } else {
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
    return Opacity(
      opacity: status == "" ? 0.5 : 1,
      child: Card(
        elevation: 1,
        shadowColor: Colors.grey,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Colors.brown[50]!,
                    Colors.brown[100]!,
                    Colors.brown[200]!,
                    Colors.brown[200]!,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 5,
              bottom: 5,
              child: Opacity(
                opacity: 0.2,
                child: device.typeId == 1
                    ? Icon(
                        FontAwesomeIcons.temperatureHigh,
                        size: 40,
                      )
                    : device.typeId == 2
                        ? Icon(
                            FontAwesomeIcons.droplet,
                            size: 40,
                          )
                        : device.typeId == 3
                            ? Icon(
                                FontAwesomeIcons.volcano,
                                size: 40,
                              )
                            : device.typeId == 4 || device.typeId == 6
                                ? Icon(
                                    FontAwesomeIcons.roadBarrier,
                                    size: 40,
                                  )
                                : device.typeId == 5
                                    ? RotatedBox(
                                        quarterTurns: 2,
                                        child: Icon(
                                          FontAwesomeIcons.lightbulb,
                                          size: 40,
                                        ),
                                      )
                                    : device.typeId == 8
                                        ? Icon(
                                            FontAwesomeIcons.faucetDrip,
                                            size: 40,
                                          )
                                        : null,
              ),
            ),
            Positioned(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width(context) * 0.02,
                  vertical: width(context) * 0.01,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            widget.device.name!.toTitleCaseTr(),
                            overflow: TextOverflow.ellipsis,
                            style: textTheme(context).labelLarge,
                          ),
                        ),
                        PopupMenuButton(
                          splashRadius: 40,
                          child: Container(
                            height: 20,
                            width: 15,
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.more_vert,
                            ),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              height: height(context) * 0.04,
                              child: Text(
                                device.favoriteSequence! > -1
                                    ? "Favorilerden Çıkar"
                                    : "Favorilere EKle",
                                style: textTheme(context).labelLarge,
                              ),
                              onTap: () async {
                                HomeController homeController = Get.find();
                                await homeController.updateFavoriteSequence(
                                    device.id!,
                                    device.favoriteSequence! > -1
                                        ? -1
                                        : homeController.homeDevices
                                            .where(
                                                (d) => d.favoriteSequence! > -1)
                                            .length);
                              },
                            ),
                            if (device.typeId! > 3)
                              PopupMenuItem(
                                height: height(context) * 0.04,
                                child: Text(
                                  "Planla",
                                  style: textTheme(context).labelLarge,
                                ),
                                onTap: () {
                                  //
                                },
                              ),
                            if (device.typeId! > 3)
                              PopupMenuItem(
                                height: height(context) * 0.04,
                                child: Text(
                                  "Konum Etkinleştir",
                                  style: textTheme(context).labelLarge,
                                ),
                                onTap: () {
                                  //
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: device.typeId! < 4 || device.typeId == 7
                            ? null
                            : () {
                                sendMessage();
                              },
                        onDoubleTap: () {
                          //
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: device.typeId == 1 ||
                                      device.typeId == 2 ||
                                      device.typeId == 3
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                              children: [
                                device.typeId == 1 ||
                                        device.typeId == 2 ||
                                        device.typeId == 3
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            status.isNotEmpty ? status : "-",
                                            style: textTheme(context)
                                                .headlineLarge,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          if (device.typeId == 1 ||
                                              device.typeId == 2 ||
                                              device.typeId == 3)
                                            Text(device.unit ?? "-"),
                                        ],
                                      )
                                    : _switch2(context),
                                Text(
                                  device.typeId == 4
                                      ? status == "1"
                                          ? "Kapalı"
                                          : status == "2"
                                              ? "Açılıyor"
                                              : status == "3"
                                                  ? "Açık"
                                                  : status == "4"
                                                      ? "Kapanıyor"
                                                      : "-"
                                      : device.typeId == 5
                                          ? status == "1"
                                              ? "Kapalı"
                                              : status == "2"
                                                  ? "Açılıyor"
                                                  : status == "3"
                                                      ? "Açık"
                                                      : status == "4"
                                                          ? "Kapanıyor"
                                                          : "-"
                                          : "",
                                  style: textTheme(context).labelMedium,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text(
                  device.boxName ?? "",
                  style: textTheme(context).labelSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _switch2(context) {
    return Column(
      children: [
        Opacity(
          opacity: status == "" ? 0.5 : 1,
          child: Card(
            elevation: 0,
            shape: CircleBorder(),
            color: device.typeId == 4 || device.typeId == 6
                ? status == "1"
                    ? Colors.red[400]
                    : status == "2"
                        ? Colors.brown[50]!
                        : status == "3"
                            ? waitingCount.isOdd
                                ? Colors.brown[50]!
                                : Colors.green
                            : status == "4"
                                ? Colors.brown[50]!
                                : Colors.red[400]
                : device.typeId == 5 || device.typeId == 8
                    ? status == "0"
                        ? Colors.brown[50]!
                        : Colors.red[400]
                    : status == "1"
                        ? Colors.brown[50]!
                        : Colors.red[400],
            child: CircularPercentIndicator(
              radius: width(context) * 0.05,
              percent: status == "2"
                  ? openCount / device.openingTime!
                  : status == "4"
                      ? closeCount / device.closingTime!
                      : waitingCount.isEven
                          ? 1
                          : 1,
              progressColor: status == "2" || status == "3"
                  ? Colors.green
                  : Colors.red[400],
              backgroundColor: Colors.brown[50]!,
              lineWidth: width(context) * 0.006,
              center: Icon(
                FontAwesomeIcons.powerOff,
                color: status == "2"
                    ? Colors.green
                    : status == "3"
                        ? waitingCount.isOdd
                            ? Colors.green
                            : Colors.brown[50]!
                        : status == "4"
                            ? Colors.red[400]
                            : Colors.brown[50]!,
                size: width(context) * 0.06,
              ),
            ),
          ),
        ),
      ],
    );
  }

  sendMessage() {
    if (_mqttController.isConnected.value) {
      if (device.typeId == 4) {
        _mqttController.publishMessage(device.topicRec!, "0");
      }
      if (device.typeId == 5) {
        _mqttController.publishMessage(
            device.topicRec!, status == "1" ? "0" : "1");
      }
      if (device.typeId == 6 && device.rfCodes != null) {
        _mqttController.publishMessage(device.topicRec!, device.rfCodes![0]);
      }
      if (device.typeId == 8) {
        _mqttController.publishMessage(
            device.topicRec!, status == "0" ? "1" : "0");
      }
      if (device.typeId == 9) {
        _mqttController.publishMessage(
            device.topicRec!, status == "1" ? "0" : "1");
      }
    }
  }
}
