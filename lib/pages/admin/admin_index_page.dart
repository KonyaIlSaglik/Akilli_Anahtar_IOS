import 'package:akilli_anahtar/controllers/user_controller.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/pages/admin/user_add_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:turkish/turkish.dart';

class AdminIndexPage extends StatefulWidget {
  const AdminIndexPage({Key? key}) : super(key: key);

  @override
  State<AdminIndexPage> createState() => _AdminIndexPageState();
}

class _AdminIndexPageState extends State<AdminIndexPage> {
  UserController userController = Get.put(UserController());
  String selectedSortOption = 'Ad Soyad';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      userController.getAll();
    });
  }

  void sortUsers(List<User> users) {
    if (selectedSortOption == 'Sıra No') {
      users.sort((a, b) => a.id.compareTo(b.id));
    } else if (selectedSortOption == 'Ad Soyad') {
      users.sort((a, b) => a.fullName.compareTo(b.fullName));
    } else if (selectedSortOption == 'Kullanıcı Adı') {
      users.sort((a, b) => a.userName.compareTo(b.userName));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        userController.searchQuery.value = "";
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
                  selectedSortOption = newValue!;
                  sortUsers(userController.users);
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
                  userController.selectedUser.value = User();
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
            preferredSize: Size.fromHeight(60.0),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Ara',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (value) {
                  setState(() {
                    userController.searchQuery.value = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: userController.getAll,
          child: Obx(() {
            if (userController.loadingUser.value) {
              return Center(child: CircularProgressIndicator());
            } else if (userController.users.isEmpty) {
              return Center(child: Text("No users found."));
            } else {
              // Filter users based on the search query
              final filteredUsers = userController.users.where((user) {
                return user.fullName.toLowerCaseTr().contains(
                        userController.searchQuery.value.toLowerCaseTr()) ||
                    user.userName.toLowerCaseTr().contains(
                        userController.searchQuery.value.toLowerCaseTr());
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
                        userController.selectedUser.value = filteredUsers[i];
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
