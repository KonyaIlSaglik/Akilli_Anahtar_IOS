import 'package:akilli_anahtar/controllers/admin/device_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ValueRangeAddEditPage extends StatefulWidget {
  const ValueRangeAddEditPage({super.key});

  @override
  State<ValueRangeAddEditPage> createState() => _ValueRangeAddEditPageState();
}

class _ValueRangeAddEditPageState extends State<ValueRangeAddEditPage> {
  DeviceManagementController deviceManagementController = Get.find();
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return ExpansionTile(
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: Text("Referans Aralıkları"),
      children: [
        SizedBox(height: 8),
        Text("Normal Değer Aralığı :"),
        Row(
          children: [
            SizedBox(
              width: width * 0.40,
              child: TextFormField(
                decoration: InputDecoration(labelText: 'Min Değer'),
                initialValue: deviceManagementController
                    .selectedDevice.value.normalMinValue
                    ?.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) => deviceManagementController
                        .selectedDevice.value.normalMinValue =
                    value.isEmpty ? null : double.tryParse(value),
              ),
            ),
            SizedBox(
              width: width * 0.10,
            ),
            SizedBox(
              width: width * 0.40,
              child: TextFormField(
                decoration: InputDecoration(labelText: 'Max Değer'),
                initialValue: deviceManagementController
                    .selectedDevice.value.normalMaxValue
                    ?.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) => deviceManagementController
                        .selectedDevice.value.normalMaxValue =
                    value.isEmpty ? null : double.tryParse(value),
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
                decoration: InputDecoration(labelText: 'Min Değer'),
                initialValue: deviceManagementController
                    .selectedDevice.value.criticalMinValue
                    ?.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) => deviceManagementController
                        .selectedDevice.value.criticalMinValue =
                    value.isEmpty ? null : double.tryParse(value),
              ),
            ),
            SizedBox(
              width: width * 0.10,
            ),
            SizedBox(
              width: width * 0.40,
              child: TextFormField(
                decoration: InputDecoration(labelText: 'Max Değer'),
                initialValue: deviceManagementController
                    .selectedDevice.value.criticalMaxValue
                    ?.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) => deviceManagementController
                        .selectedDevice.value.criticalMaxValue =
                    value.isEmpty ? null : double.tryParse(value),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
