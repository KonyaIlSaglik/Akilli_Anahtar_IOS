import 'package:akilli_anahtar/controllers/admin/device_management_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
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
    return Column(
      children: [
        Row(
          children: [Text("Normal Değer Aralığı :")],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: width * 0.43,
              child: textFormField(
                context,
                labelText: "Min Değer",
                keyboardType: TextInputType.number,
                initialValue: deviceManagementController
                    .selectedDevice.value.normalMinValue
                    ?.toString(),
                onChanged: (value) => deviceManagementController
                        .selectedDevice.value.normalMinValue =
                    value.isEmpty ? null : double.tryParse(value),
              ),
            ),
            SizedBox(
              width: width * 0.43,
              child: textFormField(
                context,
                labelText: "Max Değer",
                keyboardType: TextInputType.number,
                initialValue: deviceManagementController
                    .selectedDevice.value.normalMaxValue
                    ?.toString(),
                onChanged: (value) => deviceManagementController
                        .selectedDevice.value.normalMaxValue =
                    value.isEmpty ? null : double.tryParse(value),
              ),
            ),
          ],
        ),
        SizedBox(height: height(context) * 0.02),
        Row(
          children: [
            Text("Kritik Değer Aralığı :"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: width * 0.43,
              child: textFormField(
                context,
                labelText: "Min Değer",
                keyboardType: TextInputType.number,
                initialValue: deviceManagementController
                    .selectedDevice.value.criticalMinValue
                    ?.toString(),
                onChanged: (value) => deviceManagementController
                        .selectedDevice.value.criticalMinValue =
                    value.isEmpty ? null : double.tryParse(value),
              ),
            ),
            SizedBox(
              width: width * 0.43,
              child: textFormField(
                context,
                labelText: "Max Değer",
                keyboardType: TextInputType.number,
                initialValue: deviceManagementController
                    .selectedDevice.value.criticalMaxValue
                    ?.toString(),
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
