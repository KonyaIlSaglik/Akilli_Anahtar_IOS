import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/models/device_notification_model.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
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
  DeviceNotificationModel notificationModel =
      DeviceNotificationModel(deviceId: 0, status: DeviceNotificationModel.on);

  @override
  void initState() {
    super.initState();
    notificationModel.deviceId = widget.device.id!;
    _loadNotification();
  }

  // Veritabanından bildirimi yükle
  void _loadNotification() {
    LocalDb.get(notificationKey(widget.device.id!)).then(
      (value) {
        if (value != null) {
          setState(() {
            notificationModel = DeviceNotificationModel.fromJson(value);
            if (notificationModel.dateTime == null) {
              notificationModel.status = DeviceNotificationModel.on;
            }
          });
        }
      },
    );
  }

  void _updateNotification(DeviceNotificationModel newNotification) {
    setState(() {
      notificationModel = newNotification;
    });
    LocalDb.update(
        notificationKey(widget.device.id!), newNotification.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("${widget.device.boxName} / ${widget.device.name}"),
      subtitle: Column(
        children: [
          Row(
            children: [
              // Bildirim Açık
              TextButton(
                style: notificationModel.status == DeviceNotificationModel.on
                    ? ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.brown[100]))
                    : null,
                onPressed: () {
                  _updateNotification(DeviceNotificationModel(
                    deviceId: widget.device.id!,
                    status: DeviceNotificationModel.on,
                  ));
                },
                child: Text("Açık"),
              ),
              // 30 Dakika Erteleme
              TextButton(
                style: notificationModel.status == DeviceNotificationModel.dk30
                    ? ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.brown[100]))
                    : null,
                onPressed: () {
                  _updateNotification(DeviceNotificationModel(
                    deviceId: widget.device.id!,
                    status: DeviceNotificationModel.dk30,
                    dateTime: DateTime.now().add(Duration(minutes: 30)),
                  ));
                },
                child: Text("30 dk\nErtele"),
              ),
              TextButton(
                style: notificationModel.status == DeviceNotificationModel.dk120
                    ? ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.brown[100]))
                    : null,
                onPressed: () {
                  _updateNotification(DeviceNotificationModel(
                    deviceId: widget.device.id!,
                    status: DeviceNotificationModel.dk120,
                    dateTime: DateTime.now().add(Duration(minutes: 120)),
                  ));
                },
                child: Text("2 saat\nErtele"),
              ),
              TextButton(
                style: notificationModel.status == DeviceNotificationModel.dk480
                    ? ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.brown[100]))
                    : null,
                onPressed: () {
                  _updateNotification(DeviceNotificationModel(
                    deviceId: widget.device.id!,
                    status: DeviceNotificationModel.dk480,
                    dateTime: DateTime.now().add(Duration(minutes: 480)),
                  )); // 8 saat
                },
                child: Text("8 saat\nErtele"),
              ),
              // Bildirim Kapalı
              TextButton(
                style: notificationModel.status == DeviceNotificationModel.off
                    ? ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.brown[100]))
                    : null,
                onPressed: () {
                  _updateNotification(DeviceNotificationModel(
                    deviceId: widget.device.id!,
                    status: DeviceNotificationModel.off,
                  ));
                },
                child: Text("Kapalı"),
              ),
            ],
          ),
          if (notificationModel.status != DeviceNotificationModel.on &&
              notificationModel.status != DeviceNotificationModel.off)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Yeniden Açılma Zamanı: "),
                Text(
                  DateFormat("dd.MM.yyyy HH:mm:ss")
                      .format(notificationModel.dateTime!),
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
