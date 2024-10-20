import 'package:akilli_anahtar/controllers/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/device_management_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/entities/device.dart';
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
  late String deviceName;
  late int typeId;
  late int boxId;
  late String topicStat;
  late String topicRec;
  late String topicRes;
  late String pin;
  late String description;
  late String openingTime;
  late String waitingTime;
  late String closingTime;
  late bool active;
  late int pinMode;
  late int pintStart;
  late String repeatTransmit;

  @override
  void initState() {
    super.initState();
    deviceName = "";
    typeId = 0;
    boxId = 0;
    topicStat = "";
    topicRec = "";
    topicRes = "";
    pin = "";
    description = "";
    openingTime = "";
    waitingTime = "";
    closingTime = "";
    active = true;
    pinMode = 0;
    pintStart = 0;
    repeatTransmit = "";
    if (deviceManagementController.selectedDevice.value.id > 0) {
      deviceName = deviceManagementController.selectedDevice.value.name;
      typeId = deviceManagementController.selectedDevice.value.typeId;
      boxId = deviceManagementController.selectedDevice.value.boxId;
      topicStat = deviceManagementController.selectedDevice.value.topicStat;
      topicRec = deviceManagementController.selectedDevice.value.topicRec ?? "";
      topicRes = deviceManagementController.selectedDevice.value.topicRes ?? "";
      pin = deviceManagementController.selectedDevice.value.pin;
      description =
          deviceManagementController.selectedDevice.value.description ?? "";
      openingTime = deviceManagementController.selectedDevice.value.openingTime
          .toString();
      waitingTime = deviceManagementController.selectedDevice.value.waitingTime
          .toString();
      closingTime = deviceManagementController.selectedDevice.value.closingTime
          .toString();
      active = deviceManagementController.selectedDevice.value.active == 1;
      pinMode = deviceManagementController.selectedDevice.value.pinMode ?? 0;
      pintStart = deviceManagementController.selectedDevice.value.pinStart ?? 0;
      repeatTransmit =
          deviceManagementController.selectedDevice.value.repeatTransmit != null
              ? deviceManagementController.selectedDevice.value.repeatTransmit
                  .toString()
              : "";
    }
  }

  void _saveDevice() async {
    if (_formKey.currentState!.validate()) {
      if (deviceManagementController.selectedDevice.value.id == 0) {
        var newDevice = Device();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.90,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Cihaz Ekle",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Divider(),
            Obx(
              () {
                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (deviceManagementController.selectedDevice.value.id >
                            0)
                          DropdownButtonFormField<Box>(
                            decoration: InputDecoration(
                              labelText: "Box Türü",
                            ),
                            value: boxManagementController.boxes.singleWhere(
                              (o) =>
                                  o.id ==
                                  deviceManagementController
                                      .selectedDevice.value.boxId,
                            ),
                            items: boxManagementController.boxes.map(
                              (box) {
                                return DropdownMenuItem<Box>(
                                  value: box,
                                  child: Text(box.name),
                                );
                              },
                            ).toList(),
                            onChanged: (value) => deviceManagementController
                                .selectedTypeId.value = value?.id ?? 0,
                          ),
                        SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Cihaz Adı'),
                          initialValue: deviceName,
                          onChanged: (value) => deviceName = value,
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
                          initialValue: description,
                          onChanged: (value) => description = value,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              width: width * 0.40,
                              child: TextFormField(
                                decoration: InputDecoration(labelText: 'Pin'),
                                initialValue: pin,
                                keyboardType: TextInputType.number,
                                onChanged: (value) => pin = value,
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
                                    value: active,
                                    onChanged: (value) {
                                      setState(() {
                                        active = value ?? false;
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
                          items: deviceManagementController.deviceTypes.map(
                            (deviceType) {
                              return DropdownMenuItem<DeviceType>(
                                value: deviceType,
                                child: Text(deviceType.name),
                              );
                            },
                          ).toList(),
                          onChanged: (value) => typeId = value?.id ?? 0,
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
                                          .selectedTypeId.value,
                                )
                                    ? "INPUT"
                                    : [4, 5, 6, 8, 9].any(
                                        (t) =>
                                            t ==
                                            deviceManagementController
                                                .selectedTypeId.value,
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
                                    pinMode = value == "INPUT" ? 0 : 1,
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
                                          .selectedTypeId.value,
                                )
                                    ? "LOW"
                                    : [4, 5, 8, 9].any(
                                        (t) =>
                                            t ==
                                            deviceManagementController
                                                .selectedTypeId.value,
                                      )
                                        ? "HIGH"
                                        : deviceManagementController
                                                    .selectedTypeId.value ==
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
                                    pintStart = value == "BELİRSİZ"
                                        ? -1
                                        : value == "HIGH"
                                            ? 1
                                            : 0,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Topic Stat'),
                          initialValue: topicStat,
                          enabled: false,
                        ),
                        if ([1, 2, 3, 7].any(
                          (t) =>
                              t ==
                              deviceManagementController.selectedTypeId.value,
                        ))
                          Column(
                            children: [
                              SizedBox(height: 8),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Topic Rec'),
                                initialValue: topicRec,
                                enabled: false,
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Topic Res'),
                                initialValue: topicRes,
                                enabled: false,
                              ),
                            ],
                          ),
                        if (deviceManagementController.selectedTypeId.value ==
                            4)
                          Column(
                            children: [
                              SizedBox(height: 8),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Açılış Süresi (sn)'),
                                initialValue: openingTime,
                                keyboardType: TextInputType.number,
                                onChanged: (value) => openingTime = value,
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Açık Kalma Süresi (sn)'),
                                initialValue: waitingTime,
                                keyboardType: TextInputType.number,
                                onChanged: (value) => waitingTime = value,
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: ' Kapanma (sn)'),
                                initialValue: closingTime,
                                keyboardType: TextInputType.number,
                                onChanged: (value) => closingTime = value,
                              ),
                            ],
                          ),
                        if (deviceManagementController.selectedTypeId.value ==
                            6)
                          Column(
                            children: [
                              SizedBox(height: 8),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Gönderim sayısı'),
                                initialValue: repeatTransmit,
                                keyboardType: TextInputType.number,
                                onChanged: (value) => repeatTransmit = value,
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
          ],
        ),
      ),
    );
  }
}
