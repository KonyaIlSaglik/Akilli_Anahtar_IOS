import 'package:akilli_anahtar/controllers/user_controller.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/pages/admin/user_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminIndexPage extends StatefulWidget {
  const AdminIndexPage({Key? key}) : super(key: key);

  @override
  State<AdminIndexPage> createState() => _AdminIndexPageState();
}

class _AdminIndexPageState extends State<AdminIndexPage> {
  UserController userController = Get.put(UserController());
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    userController.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        shadowColor: Colors.black,
        title: Text("Kullanıcılar"),
        actions: [
          IconButton(
            onPressed: () {
              userController.selectedUser.value = User();
              Get.to(() => UserAddEditPage());
            },
            icon: Icon(Icons.person_add_alt),
          )
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
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (userController.loadingUser.value) {
          return Center(child: CircularProgressIndicator());
        } else if (userController.users.isEmpty) {
          return Center(child: Text("No users found."));
        } else {
          // Filter users based on the search query
          final filteredUsers = userController.users.where((user) {
            return user.fullName.toLowerCase().contains(searchQuery);
          }).toList();

          return ListView.separated(
            itemBuilder: (context, i) {
              return ListTile(
                title: Text(filteredUsers[i].fullName),
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
    );
  }
}
