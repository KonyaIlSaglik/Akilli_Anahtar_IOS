import 'package:akilli_anahtar/controllers/admin/user_management_control.dart';
import 'package:akilli_anahtar/dtos/user_dto.dart';
import 'package:akilli_anahtar/pages/managers/user/user_add_edit_auths_devices.dart';
import 'package:akilli_anahtar/pages/managers/user/user_add_edit_auths_organisations.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserAddEditAuths extends StatefulWidget {
  const UserAddEditAuths({super.key});

  @override
  State<UserAddEditAuths> createState() => _UserAddEditAuthsState();
}

class _UserAddEditAuthsState extends State<UserAddEditAuths>
    with TickerProviderStateMixin {
  late TabController tabController;
  UserDto user = UserDto();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          indicatorColor: goldColor,
          labelColor: goldColor,
          overlayColor: WidgetStatePropertyAll(goldColor.withOpacity(0.2)),
          controller: tabController,
          onTap: (value) {
            if (value == 1) {
              UserManagementController userManagementController = Get.find();
              userManagementController.filterDevices();
            }
          },
          tabs: [
            Tab(
              text: "Kurumlar",
            ),
            Tab(
              text: "Bileşenler",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          UserAddEditAuthsOrganisations(),
          UserAddEditAuthsDevices(),
        ],
      ),
    );
  }
}
