import 'package:akilli_anahtar/controllers/admin/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/admin/device_management_controller.dart';
import 'package:akilli_anahtar/pages/box_manager/box_detail/device_manager/device_detail/device_add_edit_page.dart';
import 'package:akilli_anahtar/pages/box_manager/box_detail/device_manager/device_detail/device_timing_page.dart';
import 'package:akilli_anahtar/pages/box_manager/box_detail/device_manager/device_detail/rf_options_page.dart';
import 'package:akilli_anahtar/pages/box_manager/box_detail/device_manager/device_detail/topic_detail.dart';
import 'package:akilli_anahtar/pages/box_manager/box_detail/device_manager/device_detail/value_range_add_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceDetailPage extends StatefulWidget {
  const DeviceDetailPage({super.key});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage>
    with SingleTickerProviderStateMixin {
  BoxManagementController boxManagementController = Get.find();
  DeviceManagementController deviceManagementController = Get.find();

  @override
  void initState() {
    super.initState();
    if (deviceManagementController.selectedDevice.value.id > 0) {
      deviceManagementController.selectedType.value =
          deviceManagementController.deviceTypes.singleWhere(
        (t) => t.id == deviceManagementController.selectedDevice.value.typeId,
      );
    }
  }

  void _saveDevice() async {
    deviceManagementController.selectedDevice.value.boxId =
        boxManagementController.selectedBox.value.id;
    if (deviceManagementController.selectedDevice.value.id == 0) {
      deviceManagementController
          .add(deviceManagementController.selectedDevice.value);
    } else {
      deviceManagementController
          .updateDevice(deviceManagementController.selectedDevice.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          deviceManagementController.selectedDevice.value.id == 0
              ? "Cihaz Ekle"
              : "Cihaz Düzenle",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      DeviceAddEditPage(),
                      SizedBox(height: 8),
                      TopicDetail(),
                      if ([1, 2, 3].any(
                        (t) =>
                            t ==
                            deviceManagementController.selectedType.value.id,
                      ))
                        ValueRangeAddEditPage(),
                      if (deviceManagementController.selectedType.value.id == 4)
                        DeviceTimingPage(),
                      if ([6, 7].any(
                        (t) =>
                            t ==
                            deviceManagementController.selectedType.value.id,
                      ))
                        RfOptionsPage(),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: Text(
                          "KAYDET",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          _saveDevice();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
