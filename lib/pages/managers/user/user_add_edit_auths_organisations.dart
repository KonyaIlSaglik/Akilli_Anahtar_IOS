import 'package:akilli_anahtar/controllers/admin/user_management_control.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserAddEditAuthsOrganisations extends StatefulWidget {
  const UserAddEditAuthsOrganisations({super.key});

  @override
  State<UserAddEditAuthsOrganisations> createState() =>
      _UserAddEditAuthsOrganisationsState();
}

class _UserAddEditAuthsOrganisationsState
    extends State<UserAddEditAuthsOrganisations> {
  UserManagementController userManagementController =
      Get.put(UserManagementController());
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView(
        children: homeController.organisations.map((o) {
          return ListTile(
            title: Text(o.name),
            trailing: Checkbox(
              activeColor: goldColor,
              onChanged: (bool? value) async {
                if (value != null) {
                  if (value) {
                    await userManagementController.addUserOrganisation(o.id);
                    await userManagementController.getUserDevices();
                  } else {
                    if (userManagementController
                            .selectedUser.value.organisationId ==
                        o.id) {
                      errorSnackbar(
                          "Başarısız", "Ana kurum yetkisi kaldırılamaz.");
                    } else {
                      try {
                        var organisation = userManagementController
                            .userOrganisations
                            .firstWhere((uo) => uo.organisationId == o.id);
                        await userManagementController
                            .deleteUserOrganisation(organisation.id);
                        await userManagementController.getUserDevices();
                      } catch (e) {
                        print("Claim not found: $e");
                      }
                    }
                  }
                }
              },
              value: userManagementController.userOrganisations
                  .any((uo) => uo.organisationId == o.id),
            ),
          );
        }).toList(),
      );
    });
  }
}
