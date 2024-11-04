import 'package:akilli_anahtar/controllers/admin/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/pages/box_manager/box_detail/box_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoxListItem extends StatefulWidget {
  final Box box;
  const BoxListItem({super.key, required this.box});

  @override
  State<BoxListItem> createState() => _BoxListItemState();
}

class _BoxListItemState extends State<BoxListItem> {
  BoxManagementController boxManagementController = Get.find();
  MqttController mqttController = Get.find();
  HomeController homeController = Get.find();
  late Box box;

  @override
  void initState() {
    super.initState();
    box = widget.box;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: box.isOld == -1
            ? Colors.red
            : box.isOld == 0
                ? Colors.green
                : Colors.blue,
        child: Text(box.id.toString()),
      ),
      title: Text(box.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(homeController.organisations.isNotEmpty
              ? homeController.organisations
                  .singleWhere((o) => o.id == box.organisationId)
                  .name
              : "-"),
          Text("Versiyon: ${box.version}"),
          if (box.isOld == -1)
            Text(
              "Yeni Version: ${boxManagementController.newVersion.value.version}",
              style: TextStyle(color: Colors.red),
            ),
          if (box.isOld == 0)
            Text(
              "Sürüm Güncel",
              style: TextStyle(color: Colors.green),
            ),
          if (box.isOld == 1)
            Text(
              "Test Sürüm",
              style: TextStyle(color: Colors.blue),
            ),
        ],
      ),
      onTap: () {
        boxManagementController.selectedBox.value = box;
        Get.to(() => BoxDetailPage());
      },
    );
  }
}
