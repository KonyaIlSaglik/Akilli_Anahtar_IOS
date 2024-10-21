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

  final _formKey = GlobalKey<FormState>();

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
    if (_formKey.currentState!.validate()) {
      if (deviceManagementController.selectedDevice.value.id == 0) {}
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
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.90,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Obx(
                  () {
                    return Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (deviceManagementController
                                    .selectedDevice.value.id >
                                0)
                              DropdownButtonFormField<Box>(
                                decoration: InputDecoration(
                                  labelText: "Box Türü",
                                ),
                                value:
                                    boxManagementController.selectedBox.value,
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
                              decoration:
                                  InputDecoration(labelText: 'Cihaz Adı'),
                              initialValue: deviceManagementController
                                  .selectedDevice.value.name,
                              onChanged: (value) => deviceManagementController
                                  .selectedDevice.value.name = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Cihaz Adı Zorunlu';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Açıklama'),
                              initialValue: deviceManagementController
                                  .selectedDevice.value.description,
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
                                        : deviceManagementController
                                            .selectedDevice.value.pin,
                                    items: [
                                      "D0",
                                      "D1",
                                      "D2",
                                      "D3",
                                      "D4",
                                      "D5",
                                      "D6",
                                      "D7",
                                      "D8",
                                    ].map(
                                      (data) {
                                        return DropdownMenuItem<String>(
                                          value: data,
                                          child: Text(data),
                                        );
                                      },
                                    ).toList(),
                                    onChanged: (value) =>
                                        deviceManagementController
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
                                                .selectedDevice
                                                .value
                                                .active = value! ? 1 : 0;
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
                              value: deviceManagementController
                                          .selectedType.value.id >
                                      0
                                  ? deviceManagementController
                                      .selectedType.value
                                  : null,
                              items: deviceManagementController.deviceTypes.map(
                                (deviceType) {
                                  return DropdownMenuItem<DeviceType>(
                                    value: deviceType,
                                    child: Text(deviceType.name),
                                  );
                                },
                              ).toList(),
                              onChanged: (value) => deviceManagementController
                                  .selectedType.value = value!,
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
                                          t ==
                                          deviceManagementController
                                              .selectedType.value.id,
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
                                    onChanged: (value) =>
                                        deviceManagementController
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
                                          t ==
                                          deviceManagementController
                                              .selectedType.value.id,
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
                                                        .selectedType
                                                        .value
                                                        .id ==
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
                                    onChanged: (value) =>
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
                            SizedBox(height: 8),
                            if ([1, 2, 3].any(
                              (t) =>
                                  t ==
                                  deviceManagementController
                                      .selectedType.value.id,
                            ))
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  Text("Normal Değer Aralığı :"),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: width * 0.40,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              labelText: 'Min Değer'),
                                          initialValue:
                                              deviceManagementController
                                                  .selectedDevice
                                                  .value
                                                  .normalMinValue
                                                  .toString(),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) =>
                                              deviceManagementController
                                                      .selectedDevice
                                                      .value
                                                      .normalMinValue =
                                                  double.tryParse(value) ?? 0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.10,
                                      ),
                                      SizedBox(
                                        width: width * 0.40,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              labelText: 'Max Değer'),
                                          initialValue:
                                              deviceManagementController
                                                  .selectedDevice
                                                  .value
                                                  .normalMaxValue
                                                  .toString(),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) =>
                                              deviceManagementController
                                                      .selectedDevice
                                                      .value
                                                      .normalMaxValue =
                                                  double.tryParse(value) ?? 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text("Kritik Değer Aralığı :"),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: width * 0.40,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              labelText: 'Min Değer'),
                                          initialValue:
                                              deviceManagementController
                                                  .selectedDevice
                                                  .value
                                                  .criticalMinValue
                                                  .toString(),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) =>
                                              deviceManagementController
                                                      .selectedDevice
                                                      .value
                                                      .criticalMinValue =
                                                  double.tryParse(value) ?? 0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.10,
                                      ),
                                      SizedBox(
                                        width: width * 0.40,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              labelText: 'Max Değer'),
                                          initialValue:
                                              deviceManagementController
                                                  .selectedDevice
                                                  .value
                                                  .criticalMaxValue
                                                  .toString(),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) =>
                                              deviceManagementController
                                                      .selectedDevice
                                                      .value
                                                      .criticalMaxValue =
                                                  double.tryParse(value) ?? 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            if (deviceManagementController
                                    .selectedType.value.id ==
                                4)
                              Column(
                                children: [
                                  SizedBox(height: 8),
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: 'Açılış Süresi (sn)'),
                                    initialValue: deviceManagementController
                                                .selectedDevice.value.id >
                                            0
                                        ? deviceManagementController
                                            .selectedDevice.value.openingTime
                                            .toString()
                                        : null,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) =>
                                        deviceManagementController
                                            .selectedDevice
                                            .value
                                            .openingTime = int.tryParse(value),
                                  ),
                                  SizedBox(height: 8),
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: 'Açık Kalma Süresi (sn)'),
                                    initialValue: deviceManagementController
                                                .selectedDevice.value.id >
                                            0
                                        ? deviceManagementController
                                            .selectedDevice.value.waitingTime
                                            .toString()
                                        : null,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) =>
                                        deviceManagementController
                                            .selectedDevice
                                            .value
                                            .waitingTime = int.tryParse(value),
                                  ),
                                  SizedBox(height: 8),
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: ' Kapanma (sn)'),
                                    initialValue: deviceManagementController
                                                .selectedDevice.value.id >
                                            0
                                        ? deviceManagementController
                                            .selectedDevice.value.closingTime
                                            .toString()
                                        : null,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) =>
                                        deviceManagementController
                                            .selectedDevice
                                            .value
                                            .closingTime = int.tryParse(value),
                                  ),
                                ],
                              ),
                            if (deviceManagementController
                                    .selectedType.value.id ==
                                6)
                              Column(
                                children: [
                                  SizedBox(height: 8),
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: 'Gönderim sayısı'),
                                    initialValue: deviceManagementController
                                        .selectedDevice.value.repeatTransmit
                                        .toString(),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) =>
                                        deviceManagementController
                                                .selectedDevice
                                                .value
                                                .repeatTransmit =
                                            int.tryParse(value),
                                  ),
                                ],
                              ),
                            SizedBox(height: 8),
                            if (deviceManagementController
                                    .selectedDevice.value.id >
                                0)
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Topic Stat'),
                                initialValue: deviceManagementController
                                    .selectedDevice.value.topicStat,
                                enabled: false,
                              ),
                            if (deviceManagementController
                                        .selectedDevice.value.id >
                                    0 &&
                                [4, 5, 6, 8, 9].any(
                                  (t) =>
                                      t ==
                                      deviceManagementController
                                          .selectedType.value.id,
                                ))
                              Column(
                                children: [
                                  SizedBox(height: 8),
                                  TextFormField(
                                    decoration:
                                        InputDecoration(labelText: 'Topic Rec'),
                                    initialValue: deviceManagementController
                                        .selectedDevice.value.topicRec,
                                    enabled: false,
                                  ),
                                  SizedBox(height: 8),
                                  TextFormField(
                                    decoration:
                                        InputDecoration(labelText: 'Topic Res'),
                                    initialValue: deviceManagementController
                                        .selectedDevice.value.topicRes,
                                    enabled: false,
                                  ),
                                ],
                              ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _saveDevice,
                              child: Text("Kaydet"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
