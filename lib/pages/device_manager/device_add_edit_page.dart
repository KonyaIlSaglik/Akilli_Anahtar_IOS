import 'package:akilli_anahtar/controllers/device_management_controller.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceAddEditPage extends StatefulWidget {
  const DeviceAddEditPage({super.key});

  @override
  State<DeviceAddEditPage> createState() => _DeviceAddEditPageState();
}

class _DeviceAddEditPageState extends State<DeviceAddEditPage> {
  DeviceManagementController deviceManagementController = Get.find();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.90,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Cihaz Ekle",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Divider(),
            DropdownButtonFormField<DeviceType>(
              decoration: InputDecoration(
                labelText: "Cihaz Türü",
              ),
              value: deviceManagementController.selectedTypeId.value > 0
                  ? deviceManagementController.deviceTypes.singleWhere(
                      (o) =>
                          o.id ==
                          deviceManagementController.selectedTypeId.value,
                    )
                  : deviceManagementController.deviceTypes.first,
              items: deviceManagementController.deviceTypes.map(
                (deviceType) {
                  return DropdownMenuItem<DeviceType>(
                    value: deviceType,
                    child: Text(deviceType.name),
                  );
                },
              ).toList(),
              onChanged: (value) => deviceManagementController
                  .selectedTypeId.value = value?.id ?? 0,
            ),
            // Expanded(
            //   child: Obx(() {
            //     return ListView(
            //       children: userManagementController.operationClaims.map((c) {
            //         return ListTile(
            //           title: Text(c.name),
            //           trailing: Checkbox(
            //             onChanged: (bool? value) async {
            //               if (value != null) {
            //                 if (value) {
            //                   // Adding claim
            //                   await userManagementController.addUserClaim(c.id);
            //                 } else {
            //                   // Removing claim
            //                   try {
            //                     var claim = userManagementController
            //                         .userOperationClaims
            //                         .firstWhere(
            //                             (uc) => uc.operationClaimId == c.id);
            //                     await userManagementController
            //                         .deleteUserClaim(claim.id);
            //                   } catch (e) {
            //                     // Handle the case where the claim is not found
            //                     print("Claim not found: $e");
            //                   }
            //                 }
            //               }
            //             },
            //             value: userManagementController.userOperationClaims
            //                 .any((uc) => uc.operationClaimId == c.id),
            //           ),
            //         );
            //       }).toList(),
            //     );
            //   }),
            // ),
          ],
        ),
      ),
    );
  }
}
