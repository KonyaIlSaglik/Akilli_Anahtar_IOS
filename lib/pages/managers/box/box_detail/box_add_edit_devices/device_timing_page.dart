import 'package:akilli_anahtar/controllers/admin/device_management_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
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
        return Column(
          children: [
            Row(
              children: [
                Text("Kapı Durum Süreleri :"),
              ],
            ),
            textFormField(
              context,
              labelText: "Açılış Süresi (sn)",
              keyboardType: TextInputType.number,
              initialValue: deviceManagementController.selectedDevice.value.id >
                      0
                  ? deviceManagementController.selectedDevice.value.openingTime
                      .toString()
                  : null,
              onChanged: (value) => deviceManagementController
                  .selectedDevice.value.openingTime = int.tryParse(value),
            ),
            SizedBox(height: height(context) * 0.02),
            textFormField(
              context,
              labelText: "Açık Kalma Süresi (sn)",
              keyboardType: TextInputType.number,
              initialValue: deviceManagementController.selectedDevice.value.id >
                      0
                  ? deviceManagementController.selectedDevice.value.waitingTime
                      .toString()
                  : null,
              onChanged: (value) => deviceManagementController
                  .selectedDevice.value.waitingTime = int.tryParse(value),
            ),
            SizedBox(height: height(context) * 0.02),
            textFormField(
              context,
              labelText: "Kapanma Süresi (sn)",
              keyboardType: TextInputType.number,
              initialValue: deviceManagementController.selectedDevice.value.id >
                      0
                  ? deviceManagementController.selectedDevice.value.closingTime
                      .toString()
                  : null,
              onChanged: (value) => deviceManagementController
                  .selectedDevice.value.closingTime = int.tryParse(value),
            ),
          ],
        );
      },
    );
  }

  Widget textFormField(
    BuildContext context, {
    TextEditingController? controller,
    TextInputType? keyboardType,
    String? labelText,
    String? initialValue,
    void Function(String)? onChanged,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    Widget? suffix,
  }) {
    return SizedBox(
      height: height(context) * 0.07,
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme:
              TextSelectionThemeData(selectionHandleColor: goldColor),
        ),
        child: TextFormField(
          controller: controller,
          cursorColor: goldColor,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle:
                textTheme(context).labelMedium!.copyWith(color: goldColor),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                style: BorderStyle.solid,
                color: goldColor,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                style: BorderStyle.solid,
                color: goldColor,
              ),
            ),
            suffix: suffix,
          ),
          initialValue: initialValue,
          style: textTheme(context).titleSmall,
          onChanged: onChanged,
          focusNode: focusNode,
          textInputAction:
              nextFocus == null ? TextInputAction.done : TextInputAction.next,
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(nextFocus);
          },
        ),
      ),
    );
  }
}
