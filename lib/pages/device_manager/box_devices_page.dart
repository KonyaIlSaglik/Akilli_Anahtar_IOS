import 'package:akilli_anahtar/controllers/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/device_management_controller.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
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
              DropdownButtonFormField<DeviceType>(
                decoration: InputDecoration(
                  labelText: "Cihaz Türü",
                ),
                value: deviceManagementController.selectedTypeId.value > 0
                    ? deviceManagementController.deviceTypes.singleWhere(
                        (o) =>
                            o.id ==
                            deviceManagementController.selectedTypeId.value,
                      )
                    : deviceManagementController.deviceTypes.first,
                items: deviceManagementController.deviceTypes.map(
                  (deviceType) {
                    return DropdownMenuItem<DeviceType>(
                      value: deviceType,
                      child: Text(deviceType.name),
                    );
                  },
                ).toList(),
                onChanged: (value) => deviceManagementController
                    .selectedTypeId.value = value?.id ?? 0,
              ),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return ListTile(
                      title: Text(deviceManagementController.devices[i].name),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: deviceManagementController.devices.length,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
