import 'package:akilli_anahtar/controllers/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/device_management_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/pages/box_devices_manager/box_detail/box_add_edit_page.dart';
import 'package:akilli_anahtar/pages/box_devices_manager/box_detail/box_devices_page.dart';
import 'package:akilli_anahtar/pages/box_devices_manager/device_add_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoxListPage extends StatefulWidget {
  const BoxListPage({super.key});

  @override
  State<BoxListPage> createState() => _BoxListPageState();
}

class _BoxListPageState extends State<BoxListPage>
    with SingleTickerProviderStateMixin {
  BoxManagementController boxManagementController = Get.find();
  DeviceManagementController deviceManagementController =
      Get.put(DeviceManagementController());
  late TabController _tabController;
  bool visibleAddButton = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          visibleAddButton = _tabController.index == 1;
        });
      }
    });
    init();
  }

  void init() async {
    await deviceManagementController.getDeviceTypes();
    await deviceManagementController
        .getAllByBoxId(boxManagementController.selectedBox.value.id);
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
          title: Text("Kutu ve Cihaz Bilgileri"),
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
        floatingActionButton: visibleAddButton
            ? FloatingActionButton(
                child: Icon(
                  Icons.add_circle,
                ),
                onPressed: () {
                  deviceManagementController.selectedDevice.value = Device();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return DeviceAddEditPage();
                    },
                  );
                },
              )
            : null,
      ),
    );
  }
}
