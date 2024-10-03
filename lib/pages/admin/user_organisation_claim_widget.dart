import 'package:akilli_anahtar/controllers/claim_controller.dart';
import 'package:akilli_anahtar/controllers/user_controller.dart';
import 'package:akilli_anahtar/entities/user_organisation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserOrganisationClaimWidget extends StatefulWidget {
  const UserOrganisationClaimWidget({Key? key}) : super(key: key);

  @override
  State<UserOrganisationClaimWidget> createState() =>
      _UserOrganisationClaimWidgetState();
}

class _UserOrganisationClaimWidgetState
    extends State<UserOrganisationClaimWidget> {
  UserController userController = Get.find();
  ClaimController claimController = Get.find();

  @override
  void initState() {
    super.initState();
    claimController.getAllClaims();
  }

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
                          children: claimController.organisations.map((o) {
                            return ListTile(
                              title: Text(o.name),
                              trailing: Checkbox(
                                onChanged: (bool? value) async {
                                  if (value != null) {
                                    if (value) {
                                      // Adding claim
                                      var addedUserOrganisation =
                                          await claimController
                                              .addUserOrganisation(
                                        UserOrganisation(
                                          id: 0,
                                          userId: userController
                                              .selectedUser.value.id,
                                          organisationId: o.id,
                                        ),
                                      );
                                      if (addedUserOrganisation != null) {
                                        userController.selectedUserOrganisations
                                            .add(addedUserOrganisation);
                                      }
                                    } else {
                                      // Removing claim
                                      try {
                                        var organisation = userController
                                            .selectedUserOrganisations
                                            .firstWhere((uo) =>
                                                uo.organisationId == o.id);
                                        var isDeleted = await claimController
                                            .deleteUserOrganisation(
                                                organisation.id);
                                        if (isDeleted) {
                                          userController
                                              .selectedUserOrganisations
                                              .remove(organisation);
                                        }
                                      } catch (e) {
                                        // Handle the case where the claim is not found
                                        print("Claim not found: $e");
                                      }
                                    }
                                  }
                                },
                                value: userController.selectedUserOrganisations
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
