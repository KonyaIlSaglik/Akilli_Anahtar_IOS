import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/models/notification_model.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProfilePageDeviceListItem extends StatefulWidget {
  const ProfilePageDeviceListItem({
    super.key,
    required this.device,
  });

  final HomeDeviceDto device;

  @override
  State<ProfilePageDeviceListItem> createState() =>
      _ProfilePageDeviceListItemState();
}

class _ProfilePageDeviceListItemState extends State<ProfilePageDeviceListItem> {
  HomeController homeController = Get.find();
  late NotificationModel notificationModel;

  @override
  void initState() {
    super.initState();
    notificationModel =
        NotificationModel(userId: 0, deviceId: 0, status: 1, datetime: null);
    _loadNotification();
  }

  // Veritabanından bildirimi yükle
  void _loadNotification() {
    homeController.getNotification(widget.device.id!).then(
      (value) async {
        print("${notificationKey(widget.device.id!)} --> $value");
        setState(() {
          notificationModel = value;
        });
        if (notificationModel.datetime != null) {
          if (notificationModel.datetime != null &&
              notificationModel.datetime!.isBefore(DateTime.now())) {
            setState(() {
              notificationModel.status = 1;
              notificationModel.datetime = null;
            });
            await homeController.updateNotification(notificationModel);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("${widget.device.boxName} / ${widget.device.name}"),
      subtitle: notificationModel.deviceId == 0
          ? Center()
          : Column(
              children: [
                Row(
                  children: [
                    // Bildirim Açık
                    TextButton(
                      style: notificationModel.status == 1
                          ? ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.brown[100]))
                          : null,
                      onPressed: () async {
                        setState(() {
                          notificationModel.deviceId = widget.device.id!;
                          notificationModel.status = 1;
                          notificationModel.datetime = null;
                        });
                        await homeController
                            .updateNotification(notificationModel);
                      },
                      child: Text("Açık"),
                    ),
                    // 30 Dakika Erteleme
                    TextButton(
                      style: notificationModel.status == 30
                          ? ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.brown[100]))
                          : null,
                      onPressed: () async {
                        setState(() {
                          notificationModel.deviceId = widget.device.id!;
                          notificationModel.status = 30;
                          notificationModel.datetime =
                              DateTime.now().add(Duration(minutes: 30));
                        });
                        await homeController
                            .updateNotification(notificationModel);
                      },
                      child: Text("30 dk\nErtele"),
                    ),
                    TextButton(
                      style: notificationModel.status == 120
                          ? ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.brown[100]))
                          : null,
                      onPressed: () async {
                        setState(() {
                          notificationModel.deviceId = widget.device.id!;
                          notificationModel.status = 120;
                          notificationModel.datetime =
                              DateTime.now().add(Duration(minutes: 120));
                        });
                        await homeController
                            .updateNotification(notificationModel);
                      },
                      child: Text("2 saat\nErtele"),
                    ),
                    TextButton(
                      style: notificationModel.status == 480
                          ? ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.brown[100]))
                          : null,
                      onPressed: () async {
                        setState(() {
                          notificationModel.deviceId = widget.device.id!;
                          notificationModel.status = 480;
                          notificationModel.datetime =
                              DateTime.now().add(Duration(minutes: 480));
                        });
                        await homeController
                            .updateNotification(notificationModel); // 8 saat
                      },
                      child: Text("8 saat\nErtele"),
                    ),
                    // Bildirim Kapalı
                    TextButton(
                      style: notificationModel.status == 0
                          ? ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.brown[100]))
                          : null,
                      onPressed: () async {
                        setState(() {
                          notificationModel.deviceId = widget.device.id!;
                          notificationModel.status = 0;
                          notificationModel.datetime = null;
                        });
                        await homeController
                            .updateNotification(notificationModel);
                      },
                      child: Text("Kapalı"),
                    ),
                  ],
                ),
                if (notificationModel.datetime != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Yeniden Açılma Zamanı: "),
                      Text(
                        DateFormat("dd.MM.yyyy HH:mm:ss")
                            .format(notificationModel.datetime!),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
      onTap: () {
        // Cihaz detaylarına gitmek için burayı kullanabilirsiniz
      },
    );
  }
}
