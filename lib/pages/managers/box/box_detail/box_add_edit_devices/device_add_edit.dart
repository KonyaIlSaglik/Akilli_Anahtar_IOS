import 'package:akilli_anahtar/controllers/admin/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/admin/device_management_controller.dart';
import 'package:akilli_anahtar/pages/managers/box/box_detail/box_add_edit_devices/device_add_edit_form.dart';
import 'package:akilli_anahtar/pages/managers/box/box_detail/box_add_edit_devices/device_add_edit_setting.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class DeviceAddEdit extends StatefulWidget {
  const DeviceAddEdit({super.key});

  @override
  State<DeviceAddEdit> createState() => _DeviceAddEditState();
}

class _DeviceAddEditState extends State<DeviceAddEdit>
    with SingleTickerProviderStateMixin {
  BoxManagementController boxManagementController = Get.find();
  DeviceManagementController deviceManagementController = Get.find();
  late TabController _tabController;
  bool keboardVisible = false;

  @override
  void initState() {
    super.initState();

    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          keboardVisible = visible;
        });
      }
    });

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    if (deviceManagementController.selectedDevice.value.id! > 0) {
      deviceManagementController.selectedType.value =
          deviceManagementController.deviceTypes.singleWhere(
        (t) => t.id == deviceManagementController.selectedDevice.value.typeId,
      );
    }
  }

  void _saveDevice() async {
    if (deviceManagementController.formKey.currentState!.validate()) {
      deviceManagementController.selectedDevice.value.boxId =
          boxManagementController.selectedBox.value.id;
      if (deviceManagementController.selectedDevice.value.id == 0) {
        deviceManagementController
            .add(deviceManagementController.selectedDevice.value);
      } else {
        deviceManagementController
            .updateDevice(deviceManagementController.selectedDevice.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Obx(
      () {
        return Scaffold(
          appBar: AppBar(
            elevation: 5,
            foregroundColor: goldColor,
            surfaceTintColor: goldColor,
            title: Text(deviceManagementController.selectedDevice.value.id! > 0
                ? deviceManagementController.selectedDevice.value.name!
                : "Kutu Ekle"),
            actions: [
              if (boxManagementController.selectedBox.value.id > 0)
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.trashCan,
                  ),
                  onPressed: () async {
                    await deviceManagementController.delete(
                        deviceManagementController.selectedDevice.value.id!);
                    deviceManagementController.getAll();
                    Navigator.pop(context);
                  },
                ),
            ],
            bottom: TabBar(
              indicatorColor: goldColor,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: goldColor,
              controller: _tabController,
              tabs: [
                Tab(
                  text: "Bileşen Bilgisi",
                ),
                Tab(
                  text: "Ayarlar",
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              DeviceAddEditForm(),
              DeviceAddEditSetting(),
            ],
          ),
          floatingActionButton: Visibility(
            visible: !keboardVisible,
            child: InkWell(
              onTap: () {
                _saveDevice();
              },
              child: SizedBox(
                height: height(context) * 0.06,
                width: width * 0.50,
                child: Card(
                  elevation: 5,
                  color: goldColor.withOpacity(0.7),
                  child: Center(
                    child: Text(
                      "Kaydet",
                      style: textTheme(context)
                          .titleLarge!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
