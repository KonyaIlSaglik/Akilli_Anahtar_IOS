import 'package:akilli_anahtar/controllers/box_management_controller.dart';
import 'package:akilli_anahtar/pages/device_manager/box_add_edit_page.dart';
import 'package:akilli_anahtar/pages/device_manager/box_devices_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoxPage extends StatefulWidget {
  const BoxPage({super.key});

  @override
  State<BoxPage> createState() => _BoxPageState();
}

class _BoxPageState extends State<BoxPage> {
  BoxManagementController boxManagementController = Get.find();
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
          children: [
            BoxAddEditPage(),
            BoxDevicesPage(),
          ],
        ),
      ),
    );
  }
}
