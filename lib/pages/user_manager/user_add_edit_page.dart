import 'package:akilli_anahtar/controllers/admin/user_management_control.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/pages/user_manager/user_operation_claim_list_view_widget.dart';
import 'package:akilli_anahtar/pages/user_manager/user_organisation_claim_widget.dart';
import 'package:akilli_anahtar/pages/user_manager/user_device_claim_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class UserAddEditPage extends StatefulWidget {
  const UserAddEditPage({super.key});

  @override
  State<UserAddEditPage> createState() => _UserAddEditPageState();
}

class _UserAddEditPageState extends State<UserAddEditPage>
    with TickerProviderStateMixin {
  UserManagementController userManagementControl =
      Get.put(UserManagementController());
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  late String userName;
  late String fullName;
  late String mail;
  late String telephone;
  late String password;

  @override
  void initState() {
    super.initState();
    userName = "";
    fullName = "";
    mail = "";
    telephone = "";
    password = "";
    if (userManagementControl.selectedUser.value.id > 0) {
      userName = userManagementControl.selectedUser.value.userName;
      fullName = userManagementControl.selectedUser.value.fullName;
      mail = userManagementControl.selectedUser.value.mail;
      telephone = userManagementControl.selectedUser.value.telephone;
      Future.delayed(Duration.zero, () async {
        userManagementControl.getOperationClaims();
        await userManagementControl.getUserClaims();
        await userManagementControl.getUserOrganisations();
        await userManagementControl.getBoxes();
        userManagementControl.filterBoxes();
        await userManagementControl.getDevices();
        userManagementControl.filterDevices();
        await userManagementControl.getUserDevices();
      });
    }
  }

  void _saveUser({bool isValidate = true, saveAs = false}) async {
    if (isValidate) {
      if (_formKey.currentState!.validate()) {
        if (userManagementControl.selectedUser.value.id == 0) {
          final newUser = User(
            id: 0,
            userName: userName,
            fullName: fullName,
            mail: mail,
            telephone: telephone,
            password: password,
          );
          password = "";
          await userManagementControl.register(newUser);
        } else {
          if (saveAs) {
            if (_formKey2.currentState!.validate()) {
              final newUser = User(
                id: userManagementControl.selectedUser.value.id,
                userName: userName,
                fullName: fullName,
                mail: mail,
                telephone: telephone,
                password: password,
              );
              password = "";
              await userManagementControl.saveAs(newUser);
            }
          } else {
            userManagementControl
                .updateUser(userManagementControl.selectedUser.value);
          }
        }
      }
    } else {
      if (_formKey2.currentState!.validate()) {
        userManagementControl.passUpdate(
            userManagementControl.selectedUser.value.id, password);
      }
    }
  }

  void _deleteUser() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(userManagementControl.selectedUser.value.fullName),
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
                await userManagementControl
                    .delete(userManagementControl.selectedUser.value.id);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _saveAsUser() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(userManagementControl.selectedUser.value.fullName),
          content: Text("Yeni kullanıcı olarak farklı kaydedilsin mi"),
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
                _saveUser(saveAs: true);
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
          title: Text(userManagementControl.selectedUser.value.id == 0
              ? 'Kullanıcı Ekle'
              : 'Kullanıcı Düzenle'),
          actions: [
            if (userManagementControl.selectedUser.value.id > 0)
              IconButton(
                icon: Icon(
                  userManagementControl.selectedUser.value.active == 1
                      ? FontAwesomeIcons.userCheck
                      : FontAwesomeIcons.userLock,
                  color: userManagementControl.selectedUser.value.active == 1
                      ? Colors.green
                      : Colors.grey,
                ),
                onPressed: () async {
                  userManagementControl.selectedUser.value.active =
                      userManagementControl.selectedUser.value.active == 1
                          ? 0
                          : 1;
                  await userManagementControl
                      .updateUser(userManagementControl.selectedUser.value);
                },
              ),
            if (userManagementControl.selectedUser.value.id > 0)
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
                        initialValue: userName,
                        onChanged: (value) => userName = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          var existsUser = userManagementControl.users
                              .firstWhereOrNull((u) => u.userName == value);
                          if (existsUser != null) {
                            return 'Kullanıcı adı daha önce kullanılmış';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Ad Soyad'),
                        initialValue: fullName,
                        onChanged: (value) => fullName = value,
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
                        initialValue: mail,
                        onChanged: (value) => mail = value,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Telefon'),
                        initialValue: telephone,
                        onChanged: (value) => telephone = value,
                      ),
                      if (userManagementControl.selectedUser.value.id == 0)
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
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _saveUser,
                            child: Text('Kaydet'),
                          ),
                          if (userManagementControl.selectedUser.value.id > 0)
                            ElevatedButton(
                              onPressed: _saveAsUser,
                              child: Text('Farklı Kaydet'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (userManagementControl.selectedUser.value.id > 0)
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
                        UserDeviceClaimWidget(),
                        Divider(),
                        UserOrganisationClaimWidget(),
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
