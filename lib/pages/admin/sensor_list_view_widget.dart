import 'package:akilli_anahtar/controllers/claim_controller.dart';
import 'package:akilli_anahtar/controllers/user_controller.dart';
import 'package:akilli_anahtar/entities/user_device.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SensorListViewWidget extends StatefulWidget {
  const SensorListViewWidget({Key? key}) : super(key: key);

  @override
  State<SensorListViewWidget> createState() => _SensorListViewWidgetState();
}

class _SensorListViewWidgetState extends State<SensorListViewWidget> {
  UserController userController = Get.find();
  ClaimController claimController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return claimController.filteredSensors.isEmpty
          ? Center(
              child: Text("Liste Boş"),
            )
          : ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(claimController.filteredSensors[index].name),
                  trailing: Checkbox(
                    onChanged: (value) async {
                      if (value!) {
                        var addedUserDevice =
                            await claimController.addUserDevice(
                          UserDevice(
                            id: 0,
                            userId: userController.selectedUser.value.id,
                            boxId: claimController.filteredSensors[index].boxId,
                            deviceId: claimController.filteredSensors[index].id,
                            deviceTypeId: claimController
                                .filteredSensors[index].deviceTypeId,
                          ),
                        );
                        if (addedUserDevice != null) {
                          claimController.userDevices.add(addedUserDevice);
                          setState(() {});
                        }
                      } else {
                        var userDevice = claimController.userDevices.firstWhere(
                            (ud) =>
                                ud.deviceId ==
                                    claimController.filteredSensors[index].id &&
                                ud.deviceTypeId ==
                                    claimController
                                        .filteredSensors[index].deviceTypeId);
                        var isDeleted = await claimController
                            .deleteUserDevice(userDevice.id);
                        if (isDeleted) {
                          claimController.userDevices.remove(userDevice);
                          setState(() {});
                        }
                      }
                    },
                    value: claimController.userDevices.any((ud) =>
                        ud.deviceId ==
                            claimController.filteredSensors[index].id &&
                        ud.deviceTypeId ==
                            claimController
                                .filteredSensors[index].deviceTypeId),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemCount: claimController.filteredSensors.length,
            );
    });
  }
}
