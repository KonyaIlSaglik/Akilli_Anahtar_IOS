import 'package:akilli_anahtar/pages/managers/user/user_add_edit_auths_devices.dart';
import 'package:akilli_anahtar/pages/managers/user/user_add_edit_auths_organisations.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';

class UserAddEditAuths extends StatefulWidget {
  const UserAddEditAuths({super.key});

  @override
  State<UserAddEditAuths> createState() => _UserAddEditAuthsState();
}

class _UserAddEditAuthsState extends State<UserAddEditAuths>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    print("UserAddEditAuths");
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
