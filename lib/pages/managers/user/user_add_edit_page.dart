import 'package:akilli_anahtar/controllers/admin/user_management_control.dart';
import 'package:akilli_anahtar/pages/managers/user/user_add_edit_auths.dart';
import 'package:akilli_anahtar/pages/managers/user/user_add_edit_form.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class UserAddEditPage extends StatefulWidget {
  const UserAddEditPage({super.key});

  @override
  State<UserAddEditPage> createState() => _UserAddEditPageState();
}

class _UserAddEditPageState extends State<UserAddEditPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  UserManagementController userManagementControl =
      Get.put(UserManagementController());

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    if (userManagementControl.selectedUser.value.id > 0) {
      Future.delayed(Duration.zero, () async {
        userManagementControl.getOperationClaims();
        await userManagementControl.getUserClaims();
        await userManagementControl.getUserOrganisations();
        await userManagementControl.getBoxes();
        await userManagementControl.getDevices();
        await userManagementControl.getUserDevices();
      });
    }
  }

  void _deleteUser() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(userManagementControl.selectedUser.value.fullName),
          content: Text("Kullanıcıya ait tüm bilgiler sistemden silinecektir"),
          actions: [
            TextButton(
              child: Text("Vazgeç"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("Sil"),
              onPressed: () async {
                await userManagementControl
                    .delete(userManagementControl.selectedUser.value.id);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Scaffold(
          appBar: AppBar(
            title: Text(userManagementControl.selectedUser.value.id == 0
                ? 'Kullanıcı Ekle'
                : userManagementControl.selectedUser.value.fullName),
            actions: [
              if (userManagementControl.selectedUser.value.id > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Icon(
                      FontAwesomeIcons.userXmark,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _deleteUser();
                    },
                  ),
                ),
            ],
            bottom: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: goldColor,
              labelColor: goldColor,
              overlayColor: WidgetStatePropertyAll(goldColor.withOpacity(0.2)),
              onTap: (value) {
                if (userManagementControl.selectedUser.value.id == 0) {
                  value = 0;
                }
                tabController.index = value;
              },
              controller: tabController,
              tabs: [
                Tab(
                  text: "Kullanıcı Bilgileri",
                ),
                Tab(
                  text: "Yetkiler",
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              UserAddEditForm(),
              UserAddEditAuths(),
            ],
          ),
        );
      },
    );
  }
}
