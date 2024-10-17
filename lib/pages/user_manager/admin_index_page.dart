import 'package:akilli_anahtar/controllers/user_management_control.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/pages/admin/organisation_select_widget.dart';
import 'package:akilli_anahtar/pages/user_manager/user_add_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:turkish/turkish.dart';

class AdminIndexPage extends StatefulWidget {
  const AdminIndexPage({super.key});

  @override
  State<AdminIndexPage> createState() => _AdminIndexPageState();
}

class _AdminIndexPageState extends State<AdminIndexPage> {
  UserManagementController userManagementController =
      Get.put(UserManagementController());
  Organisation? selectedOrganisation;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      userManagementController.getUsers();
      userManagementController.getOrganisations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        userManagementController.searchQuery.value = "";
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 3,
          shadowColor: Colors.black,
          title: Text("Kullanıcılar"),
          actions: [
            DropdownButton<String>(
              icon: Icon(
                FontAwesomeIcons.listUl,
                color: Colors.blue,
              ),
              dropdownColor: Colors.white,
              padding: EdgeInsets.only(top: 10),
              onChanged: (String? newValue) {
                setState(() {
                  userManagementController.selectedSortOption.value = newValue!;
                  userManagementController.sortUsers();
                });
              },
              items: <String>['Sıra No', 'Ad Soyad', 'Kullanıcı Adı']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () {
                  userManagementController.selectedUser.value = User();
                  Get.to(() => UserAddEditPage());
                },
                icon: Icon(
                  FontAwesomeIcons.userPlus,
                  color: Colors.green,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(120.0),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                children: [
                  // TODO   Kuruma göre filtrele
                  OrganisationSelectWidget(),
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Ara',
                      border: OutlineInputBorder(),
                      fillColor: Colors.transparent,
                      filled: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        userManagementController.searchQuery.value =
                            value.toLowerCase();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: userManagementController.getUsers,
          child: Obx(() {
            if (userManagementController.loadingUser.value) {
              return Center(child: CircularProgressIndicator());
            } else if (userManagementController.users.isEmpty) {
              return Center(child: Text("No users found."));
            } else {
              // Filter users based on the search query
              final filteredUsers =
                  userManagementController.users.where((user) {
                return user.fullName.toLowerCaseTr().contains(
                        userManagementController.searchQuery.value
                            .toLowerCaseTr()) ||
                    user.userName.toLowerCaseTr().contains(
                        userManagementController.searchQuery.value
                            .toLowerCaseTr());
              }).toList();
              return ListView.separated(
                itemBuilder: (context, i) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                          filteredUsers[i].id.toString()), // Display user ID
                    ),
                    title: Text(filteredUsers[i].fullName),
                    subtitle: Text(filteredUsers[i].userName),
                    trailing: IconButton(
                      icon: Icon(Icons.chevron_right),
                      onPressed: () {
                        userManagementController.selectedUser.value =
                            filteredUsers[i];
                        Get.to(() => UserAddEditPage());
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemCount: filteredUsers.length,
              );
            }
          }),
        ),
      ),
    );
  }
}
