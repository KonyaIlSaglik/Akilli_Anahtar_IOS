import 'package:akilli_anahtar/controllers/admin/user_management_control.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserOperationClaimListViewWidget extends StatefulWidget {
  const UserOperationClaimListViewWidget({super.key});

  @override
  State<UserOperationClaimListViewWidget> createState() =>
      _UserOperationClaimListViewWidgetState();
}

class _UserOperationClaimListViewWidgetState
    extends State<UserOperationClaimListViewWidget> {
  UserManagementController userManagementController = Get.find();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("İşlem Yetkileri"),
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
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    Divider(),
                    Expanded(
                      child: Obx(() {
                        return ListView(
                          children:
                              userManagementController.operationClaims.map((c) {
                            return ListTile(
                              title: Text(c.name),
                              trailing: Checkbox(
                                onChanged: (bool? value) async {
                                  if (value != null) {
                                    if (value) {
                                      await userManagementController
                                          .addUserClaim(c.id);
                                    } else {
                                      try {
                                        var claim = userManagementController
                                            .userOperationClaims
                                            .firstWhere((uc) =>
                                                uc.operationClaimId == c.id);
                                        await userManagementController
                                            .deleteUserClaim(claim.id);
                                      } catch (e) {
                                        print("Claim not found: $e");
                                      }
                                    }
                                  }
                                },
                                value: userManagementController
                                    .userOperationClaims
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
