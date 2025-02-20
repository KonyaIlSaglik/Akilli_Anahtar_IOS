import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item_action.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item_info.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item_menu_button.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item_switch.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class DeviceListViewItem extends StatefulWidget {
  final HomeDeviceDto device;

  const DeviceListViewItem({super.key, required this.device});

  @override
  State<DeviceListViewItem> createState() => _DeviceListViewItemState();
}

class _DeviceListViewItemState extends State<DeviceListViewItem> {
  final MqttController _mqttController = Get.find();
  final HomeController homeController = Get.find();
  late HomeDeviceDto device;

  @override
  void initState() {
    super.initState();
    device = widget.device;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Opacity(
          opacity: homeController.lastStatus[device.id] == "" ? 0.5 : 1,
          child: Card(
            child: Stack(
              children: [
                Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Colors.brown[50]!,
                          Colors.brown[50]!,
                          Colors.brown[100]!,
                          Colors.brown[200]!,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 5,
                  bottom: 5,
                  child: backIcon(),
                ),
                Positioned(
                  left: 5,
                  top: 5,
                  child: Text(
                    capitalizeWords(
                            device.favoriteName ?? widget.device.name) ??
                        "",
                    overflow: TextOverflow.ellipsis,
                    style: textTheme(context).labelLarge,
                  ),
                ),
                Positioned(
                  child: Center(
                    child: device.typeId == 1 ||
                            device.typeId == 2 ||
                            device.typeId == 3
                        ? DeviceListViewItemInfo(device: device)
                        : device.typeId == 4
                            ? DeviceListViewItemAction(device: device)
                            : DeviceListViewItemSwitch(device: device),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text(
                      capitalizeWords(device.boxName) ?? "",
                      style: textTheme(context).labelLarge,
                    ),
                  ),
                ),
                Visibility(
                  visible: device.typeId! > 3 || device.typeId != 7,
                  child: Positioned(
                    child: InkWell(
                      onTap: sendMessage,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 5,
                  child: DeviceListViewItemMenuButton(device: device),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget backIcon() {
    return Opacity(
      opacity: 0.2,
      child: device.typeId! == 1
          ? Icon(
              FontAwesomeIcons.temperatureHigh,
              size: 40,
            )
          : device.typeId! == 2
              ? Icon(
                  FontAwesomeIcons.droplet,
                  size: 40,
                )
              : device.typeId! == 3
                  ? Icon(
                      FontAwesomeIcons.volcano,
                      size: 40,
                    )
                  : device.typeId! == 4 || device.typeId! == 6
                      ? Icon(
                          FontAwesomeIcons.roadBarrier,
                          size: 40,
                        )
                      : device.typeId! == 5
                          ? RotatedBox(
                              quarterTurns: 2,
                              child: Icon(
                                FontAwesomeIcons.lightbulb,
                                size: 40,
                              ),
                            )
                          : device.typeId! == 8
                              ? Icon(
                                  FontAwesomeIcons.faucetDrip,
                                  size: 40,
                                )
                              : null,
    );
  }

  sendMessage() {
    if (_mqttController.isConnected.value) {
      if (device.typeId == 4) {
        _mqttController.publishMessage(device.topicRec!, "0");
      }
      if (device.typeId == 5) {
        _mqttController.publishMessage(device.topicRec!,
            homeController.lastStatus[device.id] == "1" ? "0" : "1");
      }
      if (device.typeId == 6 && device.rfCodes != null) {
        _mqttController.publishMessage(device.topicRec!, device.rfCodes![0]);
      }
      if (device.typeId == 8) {
        _mqttController.publishMessage(device.topicRec!, "0");
      }
      if (device.typeId == 9) {
        _mqttController.publishMessage(device.topicRec!,
            homeController.lastStatus[device.id] == "1" ? "0" : "1");
      }
    }
  }
}
