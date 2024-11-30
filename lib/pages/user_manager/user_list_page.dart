import 'package:akilli_anahtar/controllers/admin/user_management_control.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/organisation_select_widget.dart';
import 'package:akilli_anahtar/pages/user_manager/user_add_edit_page.dart';
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

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await userManagementController.getUsers();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            userManagementController.searchQuery.value = "";
          },
          child: Scaffold(
            appBar: AppBar(
              shadowColor: Colors.black,
              foregroundColor: goldColor,
              surfaceTintColor: goldColor,
              title: TextField(
                decoration: InputDecoration(
                  suffix: IconButton(
                      onPressed: () {
                        userManagementController.searchQuery.value = "";
                        userManagementController.filterUsers();
                      },
                      icon: Icon(FontAwesomeIcons.deleteLeft)),
                  hintText: 'Kullanıcı Ara',
                  fillColor: Colors.transparent,
                  filled: true,
                ),
                onChanged: (value) {
                  userManagementController.searchQuery.value =
                      value.toLowerCase();
                  userManagementController.filterUsers();
                },
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(
                    FontAwesomeIcons.listUl,
                  ),
                  itemBuilder: (context) =>
                      <String>['Sıra No', 'Ad Soyad', 'Kullanıcı Adı']
                          .map<PopupMenuItem<String>>(
                            (e) => PopupMenuItem<String>(child: Text(e)),
                          )
                          .toList(),
                  onSelected: (value) {
                    userManagementController.selectedSortOption.value = value;
                    userManagementController.sortUsers();
                  },
                ),
                IconButton(
                  onPressed: () {
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
                        onChanged: () async {
                          userManagementController.searchQuery.value = "";
                          await userManagementController.getUsers();
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
                  : userManagementController.users.isEmpty
                      ? Center(child: Text("No users found."))
                      : ListView.separated(
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
                                  .filteredUsers[i].fullName),
                              subtitle: Text(userManagementController
                                  .filteredUsers[i].userName),
                              trailing: IconButton(
                                icon: Icon(Icons.chevron_right),
                                hoverColor: goldColor.withOpacity(0.3),
                                onPressed: () {
                                  userManagementController.selectedUser.value =
                                      userManagementController.filteredUsers[i];
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
        );
      },
    );
  }
}
