import 'package:akilli_anahtar/controllers/user_management_control.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceListViewWidget extends StatefulWidget {
  const DeviceListViewWidget({super.key});

  @override
  State<DeviceListViewWidget> createState() => _DeviceListViewWidgetState();
}

class _DeviceListViewWidgetState extends State<DeviceListViewWidget> {
  UserManagementController userManagementController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return userManagementController.filteredDevices.isEmpty
          ? Center(
              child: Text("Liste Boş"),
            )
          : ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      userManagementController.filteredDevices[index].name),
                  trailing: Checkbox(
                    onChanged: (value) async {
                      if (value!) {
                        await userManagementController.addUserDevice(
                            userManagementController.filteredDevices[index].id);
                      } else {
                        var ud = userManagementController.userDevices
                            .firstWhere((u) =>
                                u.deviceId ==
                                userManagementController
                                    .filteredDevices[index].id);
                        await userManagementController.deleteUserDevice(ud.id);
                      }
                    },
                    value: userManagementController.userDevices.any((ud) =>
                        ud.deviceId ==
                        userManagementController.filteredDevices[index].id),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemCount: userManagementController.filteredDevices.length,
            );
    });
  }
}
