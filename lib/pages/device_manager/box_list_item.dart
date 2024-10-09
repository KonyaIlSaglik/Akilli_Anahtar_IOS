import 'package:akilli_anahtar/controllers/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/mqtt_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
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
  late Box box;

  @override
  void initState() {
    super.initState();
    box = widget.box;
    mqttController.subscribeToTopic(box.topicRes);
    mqttController.onMessage(
      (topic, message) {
        if (topic == box.topicRes) {
          if (message == "boxConnected") {
            //
          }
          if (message == "upgrading") {
            //
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(box.id.toString()), // Display user ID
      ),
      title: Text(box.name),
      //subtitle: Text(filteredBoxes[i].userName),
      trailing: IconButton(
        icon: Icon(Icons.chevron_right),
        onPressed: () {
          //boxManagementController.selectedBox.value = filteredBoxes[i];
          //Get.to(() => BoxAddEditPage());
        },
      ),
    );
  }
}
