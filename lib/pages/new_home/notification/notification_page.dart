import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/dtos/home_notification_dto.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/back_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  var list = <HomeNotificationDto>[];
  HomeController homeController = Get.find();
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    var result = await homeController.getAllNotificationMessage();

    setState(() {
      list = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[50]!,
        foregroundColor: Colors.brown[50]!,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          size: 30,
        ),
        title: Text(
          "Bildirimler",
          style: width(context) < minWidth
              ? textTheme(context).titleMedium!
              : textTheme(context).titleLarge!,
        ),
        actions: [
          //
        ],
      ),
      body: BackContainer(
        child: list.isEmpty
            ? Center()
            : ListView.separated(
                itemBuilder: (context, i) {
                  return ListTile(
                    leading: Icon(
                      deviceIcon(homeController.homeDevices
                          .singleWhere((d) => d.id == list[i].sensorId)
                          .typeId!),
                      size: 40,
                      color: list[i].alarmStatus! == 1
                          ? Colors.orange
                          : Colors.red,
                    ),
                    title: Text("${list[i].boxName!} / ${list[i].sensorName!}"),
                    subtitle: Text(
                        "Bildirim Zamanı: ${DateFormat("dd.MM.yyyy HH:mm").format(list[i].dateTime!)}"),
                  );
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: list.length,
              ),
      ),
    );
  }
}
