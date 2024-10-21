import 'package:akilli_anahtar/controllers/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/device_management_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceAddEditPage extends StatefulWidget {
  const DeviceAddEditPage({super.key});

  @override
  State<DeviceAddEditPage> createState() => _DeviceAddEditPageState();
}

class _DeviceAddEditPageState extends State<DeviceAddEditPage> {
  BoxManagementController boxManagementController = Get.find();
  DeviceManagementController deviceManagementController = Get.find();
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Obx(
      () {
        return Column(
          children: [
            if (deviceManagementController.selectedDevice.value.id > 0)
              DropdownButtonFormField<Box>(
                decoration: InputDecoration(
                  labelText: "Box Türü",
                ),
                value: boxManagementController.selectedBox.value.id > 0
                    ? boxManagementController.selectedBox.value
                    : null,
                items: boxManagementController.boxes.map(
                  (box) {
                    return DropdownMenuItem<Box>(
                      value: box,
                      child: Text(box.name),
                    );
                  },
                ).toList(),
                onChanged: (value) => deviceManagementController
                    .selectedDevice.value.boxId = value!.id,
              ),
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: 'Cihaz Adı'),
              initialValue:
                  deviceManagementController.selectedDevice.value.name,
              onChanged: (value) =>
                  deviceManagementController.selectedDevice.value.name = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Cihaz Adı Zorunlu';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: 'Açıklama'),
              initialValue:
                  deviceManagementController.selectedDevice.value.description,
              onChanged: (value) => deviceManagementController
                  .selectedDevice.value.description = value,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: width * 0.40,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Pin",
                    ),
                    value: deviceManagementController
                            .selectedDevice.value.pin.isEmpty
                        ? null
                        : deviceManagementController.selectedDevice.value.pin,
                    items: boxManagementController.espPins.map(
                      (data) {
                        return DropdownMenuItem<String>(
                          value: data,
                          child: Text(data),
                        );
                      },
                    ).toList(),
                    onChanged: (value) => deviceManagementController
                        .selectedDevice.value.pin = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pin Zorunlu';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  width: width * 0.40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Cihaz Aktif"),
                      Checkbox(
                        value: deviceManagementController
                                .selectedDevice.value.active ==
                            1,
                        onChanged: (value) {
                          setState(() {
                            deviceManagementController
                                .selectedDevice.value.active = value! ? 1 : 0;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<DeviceType>(
              decoration: InputDecoration(
                labelText: "Cihaz Türü",
              ),
              value: deviceManagementController.selectedType.value.id > 0
                  ? deviceManagementController.selectedType.value
                  : null,
              items: deviceManagementController.deviceTypes.map(
                (deviceType) {
                  return DropdownMenuItem<DeviceType>(
                    value: deviceType,
                    child: Text(deviceType.name),
                  );
                },
              ).toList(),
              onChanged: (value) =>
                  deviceManagementController.selectedType.value = value!,
              validator: (value) {
                if (value == null) {
                  return 'Cihaz Türü Zorunlu';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: width * 0.40,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Pin Mod",
                    ),
                    value: [1, 2, 3, 7].any(
                      (t) =>
                          t == deviceManagementController.selectedType.value.id,
                    )
                        ? "INPUT"
                        : [4, 5, 6, 8, 9].any(
                            (t) =>
                                t ==
                                deviceManagementController
                                    .selectedType.value.id,
                          )
                            ? "OUTPUT"
                            : null,
                    items: ["INPUT", "OUTPUT"].map(
                      (data) {
                        return DropdownMenuItem<String>(
                          value: data,
                          child: Text(data),
                        );
                      },
                    ).toList(),
                    onChanged: (value) => deviceManagementController
                        .selectedDevice
                        .value
                        .pinMode = value == "INPUT" ? 0 : 1,
                  ),
                ),
                SizedBox(
                  width: width * 0.10,
                ),
                SizedBox(
                  width: width * 0.40,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Başlangıç Durumu",
                    ),
                    value: [1, 2, 3, 6].any(
                      (t) =>
                          t == deviceManagementController.selectedType.value.id,
                    )
                        ? "LOW"
                        : [4, 5, 8, 9].any(
                            (t) =>
                                t ==
                                deviceManagementController
                                    .selectedType.value.id,
                          )
                            ? "HIGH"
                            : deviceManagementController
                                        .selectedType.value.id ==
                                    7
                                ? "BELİRSİZ"
                                : null,
                    items: ["BELİRSİZ", "HIGH", "LOW"].map(
                      (data) {
                        return DropdownMenuItem<String>(
                          value: data,
                          child: Text(data),
                        );
                      },
                    ).toList(),
                    onChanged:
                        (value) =>
                            deviceManagementController
                                    .selectedDevice.value.pinStart =
                                value == "BELİRSİZ"
                                    ? -1
                                    : value == "HIGH"
                                        ? 1
                                        : 0,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
