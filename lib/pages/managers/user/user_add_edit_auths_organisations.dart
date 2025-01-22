import 'package:akilli_anahtar/controllers/admin/user_management_control.dart';
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
  var scrollController = ScrollController();
  UserManagementController userManagementController =
      Get.put(UserManagementController());

  @override
  void initState() {
    super.initState();
    print("UserAddEditAuthsOrganisations");
    userManagementController.getAllOrganisationsWithUserAdded();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: userManagementController.umOrganisations.isEmpty
            ? Center(
                child: Text("Liste Boş"),
              )
            : Scrollbar(
                controller: scrollController,
                scrollbarOrientation: ScrollbarOrientation.right,
                thumbVisibility: true,
                child: ListView.separated(
                  controller: scrollController,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(userManagementController
                          .umOrganisations[index].name!),
                      trailing: Checkbox(
                        activeColor: goldColor,
                        onChanged: (value) async {
                          if (value!) {
                            await userManagementController.addUserOrganisation(
                                userManagementController
                                    .umOrganisations[index].id!);
                          } else {
                            if (userManagementController
                                    .umSelectedUser.value.organisationId !=
                                userManagementController
                                    .umOrganisations[index].id!) {
                              await userManagementController
                                  .deleteUserOrganisation(
                                      userManagementController
                                          .umOrganisations[index].id!);
                            } else {
                              infoSnackbar("Bilgilendirme",
                                  "Birincil kurum yetkisi kaldırılamaz");
                            }
                          }
                        },
                        value: userManagementController
                            .umOrganisations[index].userAdded,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: userManagementController.umOrganisations.length,
                ),
              ),
      );
    });
  }
}
