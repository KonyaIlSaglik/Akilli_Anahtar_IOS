import 'package:akilli_anahtar/controllers/admin/device_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RfOptionsPage extends StatefulWidget {
  const RfOptionsPage({super.key});

  @override
  State<RfOptionsPage> createState() => _RfOptionsPageState();
}

class _RfOptionsPageState extends State<RfOptionsPage> {
  DeviceManagementController deviceManagementController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return ExpansionTile(
          title: Text("RF Ayarları"),
          children: [
            if (deviceManagementController.selectedType.value.id == 6)
              TextFormField(
                decoration: InputDecoration(labelText: 'Gönderim sayısı'),
                initialValue: deviceManagementController
                    .selectedDevice.value.repeatTransmit
                    ?.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) => deviceManagementController
                    .selectedDevice.value.repeatTransmit = int.tryParse(value),
              ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Rf Kodları',
                hintText:
                    "Birden fazla kod eklemek için araya virgül(,) ekleyin",
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
              ),
              initialValue: deviceManagementController
                  .selectedDevice.value.rfCodes
                  ?.join(","),
              keyboardType: TextInputType.number,
              onChanged: (value) => deviceManagementController
                  .selectedDevice.value.rfCodes = value.split(","),
            ),
          ],
        );
      },
    );
  }
}
