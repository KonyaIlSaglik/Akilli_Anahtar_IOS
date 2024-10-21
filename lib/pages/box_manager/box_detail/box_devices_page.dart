import 'package:akilli_anahtar/controllers/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/device_management_controller.dart';
import 'package:akilli_anahtar/pages/box_manager/box_detail/device_manager/device_detail/device_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoxDevicesPage extends StatefulWidget {
  const BoxDevicesPage({super.key});

  @override
  State<BoxDevicesPage> createState() => _BoxDevicesPageState();
}

class _BoxDevicesPageState extends State<BoxDevicesPage> {
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deviceManagementController.deviceTypes
                                .singleWhere(
                                  (t) =>
                                      t.id ==
                                      deviceManagementController
                                          .devices[i].typeId,
                                )
                                .name,
                          ),
                          Text(deviceManagementController.devices[i].pin),
                        ],
                      ),
                      onTap: () {
                        deviceManagementController.selectedDevice.value =
                            deviceManagementController.devices[i];
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return DeviceDetailPage();
                          },
                        );
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
