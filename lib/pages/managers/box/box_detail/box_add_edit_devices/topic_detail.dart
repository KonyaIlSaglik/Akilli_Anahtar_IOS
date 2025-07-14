import 'package:akilli_anahtar/controllers/admin/device_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopicDetail extends StatefulWidget {
  const TopicDetail({super.key});

  @override
  State<TopicDetail> createState() => _TopicDetailState();
}

class _TopicDetailState extends State<TopicDetail> {
  DeviceManagementController deviceManagementController = Get.find();
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text("Topicler"),
      children: [
        if ([1, 2, 3].any(
          (t) => t == deviceManagementController.selectedType.value.id,
        ))
          if (deviceManagementController.selectedType.value.id == 4)
            if (deviceManagementController.selectedType.value.id == 6)
              SizedBox(height: 8),
        if (deviceManagementController.selectedDevice.value.id! > 0)
          TextFormField(
            decoration: InputDecoration(labelText: 'Topic Stat'),
            initialValue:
                deviceManagementController.selectedDevice.value.topicStat,
            enabled: false,
          ),
        if (deviceManagementController.selectedDevice.value.id! > 0 &&
            [4, 5, 6, 8, 9].any(
              (t) => t == deviceManagementController.selectedType.value.id,
            ))
          Column(
            children: [
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(labelText: 'Topic Rec'),
                initialValue:
                    deviceManagementController.selectedDevice.value.topicRec,
                enabled: false,
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(labelText: 'Topic Res'),
                initialValue:
                    deviceManagementController.selectedDevice.value.topicRes,
                enabled: false,
              ),
            ],
          ),
      ],
    );
  }
}
