import 'package:akilli_anahtar/controllers/admin/device_management_controller.dart';
import 'package:akilli_anahtar/pages/managers/box/box_detail/box_add_edit_devices/device_timing_page.dart';
import 'package:akilli_anahtar/pages/managers/box/box_detail/box_add_edit_devices/rf_options_page.dart';
import 'package:akilli_anahtar/pages/managers/box/box_detail/box_add_edit_devices/value_range_add_edit_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceAddEditSetting extends StatefulWidget {
  const DeviceAddEditSetting({super.key});

  @override
  State<DeviceAddEditSetting> createState() => _DeviceAddEditSettingState();
}

class _DeviceAddEditSettingState extends State<DeviceAddEditSetting> {
  DeviceManagementController deviceManagementController = Get.find();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: width(context) * 0.03,
          right: width(context) * 0.03,
          top: height(context) * 0.02,
        ),
        child: Column(
          children: [
            Visibility(
              visible: [1, 2, 3].any(
                (t) => t == deviceManagementController.selectedType.value.id,
              ),
              child: ValueRangeAddEditPage(),
            ),
            Visibility(
              visible: [6, 7].any(
                (t) => t == deviceManagementController.selectedType.value.id,
              ),
              child: RfOptionsPage(),
            ),
            Visibility(
              visible: deviceManagementController.selectedType.value.id == 4,
              child: DeviceTimingPage(),
            ),
          ],
        ),
      ),
    );
  }
}
