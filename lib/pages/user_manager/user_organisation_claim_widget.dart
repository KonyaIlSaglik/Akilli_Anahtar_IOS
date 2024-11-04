import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/admin/user_management_control.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserOrganisationClaimWidget extends StatefulWidget {
  const UserOrganisationClaimWidget({super.key});

  @override
  State<UserOrganisationClaimWidget> createState() =>
      _UserOrganisationClaimWidgetState();
}

class _UserOrganisationClaimWidgetState
    extends State<UserOrganisationClaimWidget> {
  UserManagementController userManagementController = Get.find();
  HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Kurum Yetkileri"),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.80,
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
                            "Kurum Yetkileri",
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
                    Expanded(
                      child: Obx(() {
                        return ListView(
                          children: homeController.organisations.map((o) {
                            return ListTile(
                              title: Text(o.name),
                              trailing: Checkbox(
                                onChanged: (bool? value) async {
                                  if (value != null) {
                                    if (value) {
                                      await userManagementController
                                          .addUserOrganisation(o.id);
                                    } else {
                                      try {
                                        var organisation =
                                            userManagementController
                                                .userOrganisations
                                                .firstWhere((uo) =>
                                                    uo.organisationId == o.id);
                                        await userManagementController
                                            .deleteUserOrganisation(
                                                organisation.id);
                                      } catch (e) {
                                        print("Claim not found: $e");
                                      }
                                    }
                                  }
                                },
                                value: userManagementController
                                    .userOrganisations
                                    .any((uo) => uo.organisationId == o.id),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
