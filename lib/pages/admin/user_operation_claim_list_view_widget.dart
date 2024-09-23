import 'package:akilli_anahtar/controllers/claim_controller.dart';
import 'package:akilli_anahtar/controllers/user_controller.dart';
import 'package:akilli_anahtar/entities/user_operation_claim.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserOperationClaimListViewWidget extends StatefulWidget {
  const UserOperationClaimListViewWidget({Key? key}) : super(key: key);

  @override
  State<UserOperationClaimListViewWidget> createState() =>
      _UserOperationClaimListViewWidgetState();
}

class _UserOperationClaimListViewWidgetState
    extends State<UserOperationClaimListViewWidget> {
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
      title: Text("İşlem Yetkileri"),
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
                            "İşlem Yetkileri",
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
                          children: claimController.operationClaims.map((c) {
                            return ListTile(
                              title: Text(c.name),
                              trailing: Checkbox(
                                onChanged: (bool? value) async {
                                  if (value != null) {
                                    if (value) {
                                      // Adding claim
                                      var addedClaim =
                                          await claimController.addUserClaim(
                                        UserOperationClaim(
                                          id: 0,
                                          userId: userController
                                              .selectedUser.value.id,
                                          operationClaimId: c.id,
                                        ),
                                      );
                                      if (addedClaim != null) {
                                        userController.selectedUserClaims
                                            .add(addedClaim);
                                      }
                                    } else {
                                      // Removing claim
                                      try {
                                        var claim = userController
                                            .selectedUserClaims
                                            .firstWhere((uc) =>
                                                uc.operationClaimId == c.id);
                                        var isDeleted = await claimController
                                            .deleteUserClaim(claim.id);
                                        if (isDeleted) {
                                          userController.selectedUserClaims
                                              .remove(claim);
                                        }
                                      } catch (e) {
                                        // Handle the case where the claim is not found
                                        print("Claim not found: $e");
                                      }
                                    }
                                  }
                                },
                                value: userController.selectedUserClaims
                                    .any((uc) => uc.operationClaimId == c.id),
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
