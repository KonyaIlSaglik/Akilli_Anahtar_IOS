import 'package:akilli_anahtar/controllers/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/device_management_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:akilli_anahtar/pages/box_manager/box_detail/box_add_edit_page.dart';
import 'package:akilli_anahtar/pages/box_manager/box_detail/device_manager/device_list_page.dart';
import 'package:akilli_anahtar/pages/box_manager/box_detail/device_manager/device_add_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoxDetailPage extends StatefulWidget {
  const BoxDetailPage({super.key});

  @override
  State<BoxDetailPage> createState() => _BoxDetailPageState();
}

class _BoxDetailPageState extends State<BoxDetailPage>
    with SingleTickerProviderStateMixin {
  BoxManagementController boxManagementController = Get.find();
  DeviceManagementController deviceManagementController =
      Get.put(DeviceManagementController());
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

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
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(boxManagementController.selectedBox.value.id > 0
              ? "Kutu Düzenle"
              : "Kutu Ekle"),
          actions: [
            //
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: "Kutu Detay",
              ),
              Tab(
                text: "Cihazlar",
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            BoxAddEditPage(),
            BoxDevicesPage(),
          ],
        ),
        floatingActionButton: _tabController.index == 1 &&
                boxManagementController.selectedBox.value.id > 0
            ? FloatingActionButton(
                child: Icon(
                  Icons.add_circle,
                ),
                onPressed: () {
                  deviceManagementController.selectedDevice.value = Device();
                  deviceManagementController.selectedType.value = DeviceType();
                  Get.to(() => DeviceAddEditPage());
                },
              )
            : null,
      ),
    );
  }
}
