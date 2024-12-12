import 'package:akilli_anahtar/controllers/admin/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/admin/device_management_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:akilli_anahtar/pages/managers/box/box_detail/box_add_edit_control.dart';
import 'package:akilli_anahtar/pages/managers/box/box_detail/box_add_edit_devices.dart';
import 'package:akilli_anahtar/pages/managers/box/box_detail/box_add_edit_form.dart';
import 'package:akilli_anahtar/pages/managers/box/box_detail/box_add_edit_devices/device_add_edit.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class BoxAddEdit extends StatefulWidget {
  const BoxAddEdit({super.key});

  @override
  State<BoxAddEdit> createState() => _BoxAddEditState();
}

class _BoxAddEditState extends State<BoxAddEdit>
    with SingleTickerProviderStateMixin {
  BoxManagementController boxManagementController = Get.find();
  DeviceManagementController deviceManagementController =
      Get.put(DeviceManagementController());
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    init();
  }

  void init() async {
    await deviceManagementController.getDeviceTypes();
    if (boxManagementController.selectedBox.value.id > 0) {
      await deviceManagementController
          .getAllByBoxId(boxManagementController.selectedBox.value.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Scaffold(
          appBar: AppBar(
            elevation: 5,
            foregroundColor: goldColor,
            surfaceTintColor: goldColor,
            title: Text(boxManagementController.selectedBox.value.id > 0
                ? boxManagementController.selectedBox.value.name
                : "Kutu Ekle"),
            actions: [
              Visibility(
                visible: boxManagementController.selectedBox.value.id > 0 &&
                    _tabController.index == 0,
                child: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.trashCan,
                  ),
                  onPressed: () async {
                    await boxManagementController
                        .delete(boxManagementController.selectedBox.value.id);
                    boxManagementController.checkNewVersion();
                    boxManagementController.getBoxes();
                    Navigator.pop(context);
                  },
                ),
              ),
              Visibility(
                visible: boxManagementController.selectedBox.value.id > 0 &&
                    _tabController.index == 1,
                child: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.solidSquarePlus,
                  ),
                  onPressed: () async {
                    deviceManagementController.selectedDevice.value = Device();
                    deviceManagementController.selectedType.value =
                        DeviceType();
                    Get.to(() => DeviceAddEdit());
                  },
                ),
              ),
            ],
            bottom: TabBar(
              indicatorColor: goldColor,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: goldColor,
              controller: _tabController,
              onTap: (value) {
                if (boxManagementController.selectedBox.value.id == 0) {
                  _tabController.index = 0;
                }
              },
              tabs: [
                Tab(
                  text: "Kutu Bilgileri",
                ),
                Tab(
                  text: "Bileşenler",
                ),
                Tab(
                  text: "Kontrol",
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              BoxAddEditForm(),
              BoxAddEditDevices(),
              BoxAddEditControl(),
            ],
          ),
        );
      },
    );
  }
}
