import 'package:akilli_anahtar/controllers/admin/user_management_control.dart';
import 'package:akilli_anahtar/dtos/user_dto.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/organisation_select_widget.dart';
import 'package:akilli_anahtar/pages/managers/user/user_add_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  UserManagementController userManagementController =
      Get.put(UserManagementController());
  Organisation? selectedOrganisation;

  var scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await userManagementController.getUsers();
      await userManagementController.getAllOrganisations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            userManagementController.userSearchQuery.value = "";
          },
          child: Scaffold(
            appBar: AppBar(
              shadowColor: Colors.black,
              foregroundColor: goldColor,
              surfaceTintColor: goldColor,
              title: Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme:
                      TextSelectionThemeData(selectionHandleColor: goldColor),
                ),
                child: TextField(
                  cursorColor: goldColor,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: goldColor),
                    ),
                    suffix: IconButton(
                        onPressed: () {
                          userManagementController.userSearchQuery.value = "";
                          userManagementController.filterUsers();
                        },
                        icon: Icon(FontAwesomeIcons.deleteLeft)),
                    hintText: 'Kullanıcı Ara',
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                  onChanged: (value) {
                    userManagementController.userSearchQuery.value =
                        value.toLowerCase();
                    userManagementController.filterUsers();
                  },
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(
                    FontAwesomeIcons.listUl,
                  ),
                  itemBuilder: (context) => userOrderItems
                      .map<PopupMenuItem<String>>(
                        (e) => PopupMenuItem<String>(
                          child: Text(e),
                          onTap: () {
                            userManagementController.selectedSortOption.value =
                                e;
                            userManagementController.sortUsers();
                          },
                        ),
                      )
                      .toList(),
                ),
                IconButton(
                  onPressed: () {
                    userManagementController.umSelectedUser.value = UserDto();
                    Get.to(() => UserAddEditPage());
                  },
                  icon: Icon(FontAwesomeIcons.userPlus, color: goldColor),
                ),
                SizedBox(width: width(context) * 0.02),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(55.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      OrganisationSelectWidget(
                        list: userManagementController.organisationList,
                        selectedId: userManagementController
                            .umListSelectedOrganisationId.value,
                        onChanged: (int id) {
                          userManagementController
                              .umListSelectedOrganisationId.value = id;
                          userManagementController.filterUsers();
                        },
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: userManagementController.getUsers,
              child: userManagementController.loadingUser.value
                  ? Center(child: CircularProgressIndicator())
                  : userManagementController.filteredUsers.isEmpty
                      ? Center(child: Text("No users found."))
                      : Scrollbar(
                          controller: scrollController,
                          scrollbarOrientation: ScrollbarOrientation.right,
                          thumbVisibility: true,
                          child: ListView.separated(
                            controller: scrollController,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, i) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: goldColor.withOpacity(0.8),
                                  child: Text(
                                    userManagementController.filteredUsers[i].id
                                        .toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(userManagementController
                                    .filteredUsers[i].fullName!),
                                subtitle: Text(userManagementController
                                    .filteredUsers[i].userName!),
                                trailing: IconButton(
                                  icon: Icon(Icons.chevron_right),
                                  hoverColor: goldColor.withOpacity(0.3),
                                  onPressed: () {
                                    userManagementController
                                            .umSelectedUser.value =
                                        userManagementController
                                            .filteredUsers[i]
                                            .copyWith();
                                    Get.to(() => UserAddEditPage());
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Divider(
                                color: goldColor,
                              );
                            },
                            itemCount:
                                userManagementController.filteredUsers.length,
                          ),
                        ),
            ),
          ),
        );
      },
    );
  }
}
