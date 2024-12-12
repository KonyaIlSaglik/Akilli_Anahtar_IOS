import 'package:akilli_anahtar/controllers/admin/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/admin/device_management_controller.dart';
import 'package:akilli_anahtar/pages/managers/box/box_detail/box_add_edit_devices/device_add_edit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoxAddEditDevices extends StatefulWidget {
  const BoxAddEditDevices({super.key});

  @override
  State<BoxAddEditDevices> createState() => _BoxAddEditDevicesState();
}

class _BoxAddEditDevicesState extends State<BoxAddEditDevices> {
  BoxManagementController boxManagementController = Get.find();
  DeviceManagementController deviceManagementController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, i) {
                    return ListTile(
                      leading: Text(
                        deviceManagementController.devices[i].id.toString(),
                        style: TextStyle(fontSize: 20),
                      ),
                      title: Text(deviceManagementController.devices[i].name),
                      subtitle: Text(
                        deviceManagementController.deviceTypes
                            .singleWhere(
                              (t) =>
                                  t.id ==
                                  deviceManagementController.devices[i].typeId,
                            )
                            .name,
                      ),
                      trailing: Text(deviceManagementController.devices[i].pin),
                      onTap: () {
                        deviceManagementController.selectedDevice.value =
                            deviceManagementController.devices[i];
                        Get.to(() => DeviceAddEdit());
                      },
                    );
                  },
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: deviceManagementController.devices.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
