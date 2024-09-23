import 'package:akilli_anahtar/controllers/claim_controller.dart';
import 'package:akilli_anahtar/controllers/user_controller.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/register_model.dart';
import 'package:akilli_anahtar/pages/admin/box_select_widget.dart';
import 'package:akilli_anahtar/pages/admin/device_tab_controller_widget.dart';
import 'package:akilli_anahtar/pages/admin/organisation_select_widget.dart';
import 'package:akilli_anahtar/pages/admin/user_operation_claim_list_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class UserAddEditPage extends StatefulWidget {
  const UserAddEditPage({Key? key}) : super(key: key);

  @override
  State<UserAddEditPage> createState() => _UserAddEditPageState();
}

class _UserAddEditPageState extends State<UserAddEditPage>
    with TickerProviderStateMixin {
  UserController userController = Get.find();
  ClaimController claimController = Get.put(ClaimController());
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  late String password;

  @override
  void initState() {
    super.initState();
    password = "";
    Future.delayed(Duration.zero, () async {
      claimController.getAllClaims();
      var claims = await claimController
          .getAllUserClaims(userController.selectedUser.value.id);
      if (claims != null) {
        userController.selectedUserClaims.value = claims;
      }
      await claimController.getOrganisations();
      await claimController.getBoxes();
      claimController.filterBoxes();
      await claimController.getRelays();
      claimController.filterRelays();
      await claimController.getSensors();
      claimController.filterSensors();
      await claimController
          .getAllUserDevice(userController.selectedUser.value.id);
    });
  }

  void _saveUser({bool isValidate = true}) async {
    if (isValidate) {
      if (_formKey.currentState!.validate()) {
        if (userController.selectedUser.value.id == 0) {
          final newUser = RegisterModel(
            userName: userController.selectedUser.value.userName,
            fullName: userController.selectedUser.value.fullName,
            email: userController.selectedUser.value.mail,
            tel: userController.selectedUser.value.telephone,
            password: password,
          );
          password = "";
          userController.register(newUser);
        } else {
          userController.updateUser(userController.selectedUser.value);
        }
      }
    } else {
      if (_formKey2.currentState!.validate()) {
        userController.passUpdate(
            userController.selectedUser.value.id, password);
      }
    }
  }

  void _deleteUser() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(userController.selectedUser.value.fullName),
          content: Text("Kullanıcıya ait tüm bilgiler sistemden silinecektir"),
          actions: [
            TextButton(
              child: Text("Vazgeç"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("Sil"),
              onPressed: () async {
                await userController
                    .delete(userController.selectedUser.value.id);
                userController.users.remove(userController.selectedUser.value);
                userController.selectedUser.value = User();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: Text(userController.selectedUser.value.id == 0
              ? 'Kullanıcı Ekle'
              : 'Kullanıcı Düzenle'),
          actions: [
            if (userController.selectedUser.value.id > 0)
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.solidCopy,
                  color: Colors.blue,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Kullanıcı Kopyalama"),
                        content: Text(
                            "Kopya(${userController.selectedUser.value.userName}) kullanıcısı oluşturulsun mu?"),
                        actions: [
                          TextButton(
                            child: Text("Vazgeç"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: Text("Kopyala"),
                            onPressed: () async {
                              await userController.copySelectedUser();
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            if (userController.selectedUser.value.id > 0)
              IconButton(
                icon: Icon(
                  userController.selectedUser.value.active == 1
                      ? FontAwesomeIcons.userCheck
                      : FontAwesomeIcons.userLock,
                  color: userController.selectedUser.value.active == 1
                      ? Colors.green
                      : Colors.grey,
                ),
                onPressed: () async {
                  userController.selectedUser.value.active =
                      userController.selectedUser.value.active == 1 ? 0 : 1;
                  await userController
                      .updateUser(userController.selectedUser.value);
                  setState(() {});
                },
              ),
            if (userController.selectedUser.value.id > 0)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.userXmark,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _deleteUser();
                  },
                ),
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Kullanıcı Adı'),
                        initialValue:
                            userController.selectedUser.value.userName,
                        onChanged: (value) =>
                            userController.selectedUser.value.userName = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Ad Soyad'),
                        initialValue:
                            userController.selectedUser.value.fullName,
                        onChanged: (value) =>
                            userController.selectedUser.value.fullName = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a full name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Email'),
                        initialValue: userController.selectedUser.value.mail,
                        onChanged: (value) =>
                            userController.selectedUser.value.mail = value,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'Please enter an email';
                        //   }
                        //   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        //     return 'Please enter a valid email';
                        //   }
                        //   return null;
                        // },
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Telefon'),
                        initialValue:
                            userController.selectedUser.value.telephone,
                        onChanged: (value) =>
                            userController.selectedUser.value.telephone = value,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'Please enter a telephone number';
                        //   }
                        //   return null;
                        // },
                      ),
                      if (userController.selectedUser.value.id == 0)
                        Column(
                          children: [
                            SizedBox(height: 8),
                            TextFormField(
                              decoration: InputDecoration(labelText: 'Şifre'),
                              initialValue: password,
                              onChanged: (value) => password = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Boş geçilemez';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saveUser,
                        child: Text('Kaydet'),
                      ),
                    ],
                  ),
                ),
                if (userController.selectedUser.value.id > 0)
                  Form(
                    key: _formKey2,
                    child: Column(
                      children: [
                        Divider(),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Şifre'),
                          initialValue: password,
                          onChanged: (value) => password = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Boş geçilemez';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _saveUser(isValidate: false);
                          },
                          child: Text('Güncelle'),
                        ),
                        Divider(),
                        UserOperationClaimListViewWidget(),
                        Divider(),
                        ListTile(
                          title: Text("Cihaz Yetkileri"),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled:
                                  true, // Allows for scrolling if content is large
                              builder: (context) {
                                return SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.95, // Makes it responsive
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        16.0), // Optional padding
                                    child: Column(
                                      mainAxisSize:
                                          MainAxisSize.min, // Wraps content
                                      children: [
                                        // Title for the modal
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Text(
                                                "Cihaz Yetkileri",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                Navigator.pop(
                                                    context); // Closes the modal
                                              },
                                            ),
                                          ],
                                        ),
                                        Divider(), // Optional divider for separation
                                        OrganisationSelectWidget(),
                                        SizedBox(height: 8),
                                        BoxSelectWidget(),
                                        SizedBox(height: 8),
                                        Expanded(
                                          child: DeviceTabControllerWidget(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
