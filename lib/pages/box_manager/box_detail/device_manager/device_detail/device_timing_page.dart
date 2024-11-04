import 'package:akilli_anahtar/controllers/admin/device_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceTimingPage extends StatefulWidget {
  const DeviceTimingPage({super.key});

  @override
  State<DeviceTimingPage> createState() => _DeviceTimingPageState();
}

class _DeviceTimingPageState extends State<DeviceTimingPage> {
  DeviceManagementController deviceManagementController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return ExpansionTile(
          title: Text("Kapı Durum Süreleri"),
          children: [
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: 'Açılış Süresi (sn)'),
              initialValue: deviceManagementController.selectedDevice.value.id >
                      0
                  ? deviceManagementController.selectedDevice.value.openingTime
                      .toString()
                  : null,
              keyboardType: TextInputType.number,
              onChanged: (value) => deviceManagementController
                  .selectedDevice.value.openingTime = int.tryParse(value),
            ),
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: 'Açık Kalma Süresi (sn)'),
              initialValue: deviceManagementController.selectedDevice.value.id >
                      0
                  ? deviceManagementController.selectedDevice.value.waitingTime
                      .toString()
                  : null,
              keyboardType: TextInputType.number,
              onChanged: (value) => deviceManagementController
                  .selectedDevice.value.waitingTime = int.tryParse(value),
            ),
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: ' Kapanma (sn)'),
              initialValue: deviceManagementController.selectedDevice.value.id >
                      0
                  ? deviceManagementController.selectedDevice.value.closingTime
                      .toString()
                  : null,
              keyboardType: TextInputType.number,
              onChanged: (value) => deviceManagementController
                  .selectedDevice.value.closingTime = int.tryParse(value),
            ),
          ],
        );
      },
    );
  }
}
