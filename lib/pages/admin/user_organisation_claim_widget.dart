import 'package:akilli_anahtar/controllers/user_management_control.dart';
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Kurum Yetkileri"),
      onTap: () {
        // Show modal bottom sheet when tapped
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.80, // Adjust height as needed
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Title for the modal
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
                            Navigator.pop(context); // Closes the modal
                          },
                        ),
                      ],
                    ),
                    Divider(), // Optional divider for separation
                    Expanded(
                      child: Obx(() {
                        return ListView(
                          children:
                              userManagementController.organisations.map((o) {
                            return ListTile(
                              title: Text(o.name),
                              trailing: Checkbox(
                                onChanged: (bool? value) async {
                                  if (value != null) {
                                    if (value) {
                                      // Adding claim
                                      await userManagementController
                                          .addUserOrganisation(o.id);
                                    } else {
                                      // Removing claim
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
                                        // Handle the case where the claim is not found
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
