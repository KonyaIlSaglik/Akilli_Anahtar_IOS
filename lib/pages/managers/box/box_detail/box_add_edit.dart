import 'package:akilli_anahtar/controllers/admin/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/admin/device_management_controller.dart';
import 'package:akilli_anahtar/dtos/bm_box_dto.dart';
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
  final BmBoxDto? box;
  const BoxAddEdit({super.key, this.box});

  @override
  State<BoxAddEdit> createState() => _BoxAddEditState();
}

class _BoxAddEditState extends State<BoxAddEdit>
    with SingleTickerProviderStateMixin {
  BoxManagementController boxManagementController = Get.find();
  DeviceManagementController deviceManagementController =
      Get.put(DeviceManagementController());
  late BmBoxDto box;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    box = widget.box ?? BmBoxDto();
    _tabController = TabController(length: 3, vsync: this);
    init();
  }

  void init() async {
    if (box.id != null) {
      await deviceManagementController.getAllByBoxId(box.id!);
      await deviceManagementController.getDeviceTypes();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        foregroundColor: goldColor,
        surfaceTintColor: goldColor,
        title: Text(box.id != null ? box.name! : "Kutu Ekle"),
        actions: [
          Visibility(
            visible: box.id != null && _tabController.index == 0,
            child: IconButton(
              icon: Icon(
                FontAwesomeIcons.trashCan,
              ),
              onPressed: () async {
                await boxManagementController.delete(box.id!);
                boxManagementController.checkNewVersion();
                boxManagementController.getBoxes();
                Navigator.pop(context);
              },
            ),
          ),
          Visibility(
            visible: box.id != null && _tabController.index == 1,
            child: IconButton(
              icon: Icon(
                FontAwesomeIcons.solidSquarePlus,
              ),
              onPressed: () async {
                deviceManagementController.selectedDevice.value = Device();
                deviceManagementController.selectedType.value = DeviceType();
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
            if (box.id == null) {
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
          BoxAddEditForm(box: box),
          BoxAddEditDevices(boxId: box.id ?? 0),
          BoxAddEditControl(box: box),
        ],
      ),
    );
  }
}
