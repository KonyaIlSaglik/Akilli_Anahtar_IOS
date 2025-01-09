import 'package:akilli_anahtar/controllers/admin/user_management_control.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class UserAddEditAuthsDevices extends StatefulWidget {
  const UserAddEditAuthsDevices({super.key});

  @override
  State<UserAddEditAuthsDevices> createState() =>
      _UserAddEditAuthsDevicesState();
}

class _UserAddEditAuthsDevicesState extends State<UserAddEditAuthsDevices> {
  UserManagementController userManagementController = Get.find();
  var scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8),
        Obx(() {
          return Expanded(
            child: Column(
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme:
                        TextSelectionThemeData(selectionHandleColor: goldColor),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: width(context) * 0.05),
                    child: TextField(
                      cursorColor: goldColor,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: goldColor),
                        ),
                        suffix: IconButton(
                            onPressed: () {
                              userManagementController.deviceSearchQuery.value =
                                  "";
                              userManagementController.filterUsers();
                            },
                            icon: Icon(FontAwesomeIcons.deleteLeft)),
                        hintText: 'Ara',
                        fillColor: Colors.transparent,
                        filled: true,
                      ),
                      onChanged: (value) {
                        userManagementController.deviceSearchQuery.value =
                            value.toLowerCase();
                        userManagementController.filterDevices();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: userManagementController.umDevices.isEmpty
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
                                    .umDevices[index].name!),
                                subtitle: Text(userManagementController
                                        .umDevices[index].boxName ??
                                    ""),
                                trailing: Checkbox(
                                  activeColor: goldColor,
                                  onChanged: (value) async {
                                    if (value!) {
                                      await userManagementController
                                          .addUserDevice(
                                              userManagementController
                                                  .umDevices[index].id!);
                                    } else {
                                      var ud = userManagementController
                                          .userDevices
                                          .firstWhere((u) =>
                                              u.deviceId ==
                                              userManagementController
                                                  .umDevices[index].id);
                                      await userManagementController
                                          .deleteUserDevice(ud.id);
                                    }
                                    userManagementController.filterDevices();
                                  },
                                  value: userManagementController
                                      .umDevices[index].userAdded,
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Divider();
                            },
                            itemCount:
                                userManagementController.umDevices.length,
                          ),
                        ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
