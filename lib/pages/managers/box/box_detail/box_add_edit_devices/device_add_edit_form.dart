import 'package:akilli_anahtar/controllers/admin/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/admin/device_management_controller.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/utils/validate_listener.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceAddEditForm extends StatefulWidget {
  const DeviceAddEditForm({super.key});

  @override
  State<DeviceAddEditForm> createState() => _DeviceAddEditFormState();
}

class _DeviceAddEditFormState extends State<DeviceAddEditForm>
    implements ValidateListener {
  BoxManagementController boxManagementController = Get.find();
  DeviceManagementController deviceManagementController = Get.find();
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Obx(
      () {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: SingleChildScrollView(
            child: Form(
              key: deviceManagementController.formKey,
              child: Column(
                children: [
                  SizedBox(height: 16),
                  textFormField(
                    context,
                    0,
                    labelText: "Cihaz Adı",
                    initialValue:
                        deviceManagementController.selectedDevice.value.name,
                    onChanged: (value) => deviceManagementController
                        .selectedDevice.value.name = value,
                  ),
                  textFormField(
                    context,
                    1,
                    labelText: "Açıklama",
                    initialValue: deviceManagementController
                        .selectedDevice.value.description,
                    onChanged: (value) => deviceManagementController
                        .selectedDevice.value.description = value,
                  ),
                  SizedBox(
                    height: height(context) * 0.07,
                    child: DropdownButtonFormField<DeviceType>(
                      decoration: InputDecoration(
                        labelText: "Cihaz Türü",
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: width * 0.03),
                        labelStyle: textTheme(context)
                            .labelMedium!
                            .copyWith(color: goldColor),
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
                      ),
                      value:
                          deviceManagementController.selectedType.value.id > 0
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
                      onChanged: (value) {
                        deviceManagementController.selectedType.value = value!;
                        deviceManagementController.selectedDevice.value.typeId =
                            value.id;
                        deviceManagementController
                            .selectedDevice.value.typeName = value.name;
                        if ([1, 2, 3, 7].any(
                          (t) =>
                              t ==
                              deviceManagementController.selectedType.value.id,
                        )) {
                          deviceManagementController
                              .selectedDevice.value.pinMode = 0;
                        }
                        if ([4, 5, 6, 8, 9].any(
                          (t) =>
                              t ==
                              deviceManagementController.selectedType.value.id,
                        )) {
                          deviceManagementController
                              .selectedDevice.value.pinMode = 1;
                        }
                        if ([1, 2, 3, 6].any(
                          (t) =>
                              t ==
                              deviceManagementController.selectedType.value.id,
                        )) {
                          deviceManagementController
                              .selectedDevice.value.pinStart = 0;
                        }
                        if ([4, 5, 8, 9].any(
                          (t) =>
                              t ==
                              deviceManagementController.selectedType.value.id,
                        )) {
                          deviceManagementController
                              .selectedDevice.value.pinStart = 1;
                        }
                        if (deviceManagementController.selectedType.value.id ==
                            7) {
                          {
                            deviceManagementController
                                .selectedDevice.value.pinStart = -1;
                          }
                        }
                        deviceManagementController
                            .selectedDevice.value.repeatTransmit = null;
                        deviceManagementController
                            .selectedDevice.value.rfCodes = null;
                        deviceManagementController
                            .selectedDevice.value.openingTime = null;
                        deviceManagementController
                            .selectedDevice.value.waitingTime = null;
                        deviceManagementController
                            .selectedDevice.value.closingTime = null;
                        deviceManagementController
                            .selectedDevice.value.normalValueRangeId = 0;
                        deviceManagementController
                            .selectedDevice.value.normalMinValue = null;
                        deviceManagementController
                            .selectedDevice.value.normalMaxValue = null;
                        deviceManagementController
                            .selectedDevice.value.criticalValueRangeId = 0;
                        deviceManagementController
                            .selectedDevice.value.criticalMinValue = null;
                        deviceManagementController
                            .selectedDevice.value.criticalMaxValue = null;
                        deviceManagementController.selectedDevice.value.unitId =
                            0;
                        deviceManagementController.selectedDevice.value.unit =
                            null;
                      },
                      validator: (value) {
                        return validate(2, value?.name);
                      },
                    ),
                  ),
                  SizedBox(height: height(context) * 0.03),
                  SizedBox(
                    height: height(context) * 0.07,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Pin",
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: width * 0.03),
                        labelStyle: textTheme(context)
                            .labelMedium!
                            .copyWith(color: goldColor),
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
                        return validate(3, value);
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: width * 0.43,
                        height: height(context) * 0.07,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Pin Mod",
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: width * 0.03),
                            labelStyle: textTheme(context)
                                .labelMedium!
                                .copyWith(color: goldColor),
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
                          onChanged: (value) => deviceManagementController
                              .selectedDevice
                              .value
                              .pinMode = value == "INPUT" ? 0 : 1,
                        ),
                      ),
                      SizedBox(
                        width: width * 0.43,
                        height: height(context) * 0.07,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Başlangıç Durumu",
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: width * 0.03),
                            labelStyle: textTheme(context)
                                .labelMedium!
                                .copyWith(color: goldColor),
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
                          onChanged: (value) => deviceManagementController
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
                  SizedBox(height: 16),
                  // InkWell(
                  //   onTap: () {
                  //     //_saveDevice();
                  //   },
                  //   child: SizedBox(
                  //     height: height(context) * 0.06,
                  //     width: width * 0.50,
                  //     child: Card(
                  //       elevation: 5,
                  //       color: goldColor.withOpacity(0.7),
                  //       child: Center(
                  //         child: Text(
                  //           "Kaydet",
                  //           style: textTheme(context)
                  //               .titleLarge!
                  //               .copyWith(color: Colors.white),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget textFormField(
    BuildContext context,
    int formIndex, {
    TextEditingController? controller,
    String? labelText,
    String? initialValue,
    void Function(String)? onChanged,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    Widget? suffix,
  }) {
    return SizedBox(
      height: height(context) * 0.10,
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme:
              TextSelectionThemeData(selectionHandleColor: goldColor),
        ),
        child: TextFormField(
          controller: controller,
          cursorColor: goldColor,
          decoration: InputDecoration(
            helperText: "",
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
          validator: (value) {
            return validate(formIndex, value);
          },
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

  @override
  String? validate(int formIndex, String? value) {
    //late var actions = <String>["save", "saveAs", "update", "passUpdate"];
    print("$formIndex : $value");
    if (value == null || value.isEmpty) {
      if (formIndex == 0) return "Cihaz adı boş olamaz";
      if (formIndex == 2) return "Cihaz türü seçiniz";
      if (formIndex == 3) return "Pin seçiniz";
      if (formIndex == 3 || formIndex == 4) return null;
      if (formIndex == 2) {
        //
      }
    } else {
      //
    }
    return null;
  }
}
