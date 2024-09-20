import 'package:akilli_anahtar/controllers/claim_controller.dart';
import 'package:akilli_anahtar/controllers/user_controller.dart';
import 'package:akilli_anahtar/entities/user_operation_claim.dart';
import 'package:akilli_anahtar/models/register_model.dart';
import 'package:akilli_anahtar/pages/admin/admin_index_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserAddEditPage extends StatefulWidget {
  const UserAddEditPage({Key? key}) : super(key: key);

  @override
  State<UserAddEditPage> createState() => _UserAddEditPageState();
}

class _UserAddEditPageState extends State<UserAddEditPage> {
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
                Get.to(() => AdminIndexPage());
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
                  userController.selectedUser.value.active == 1
                      ? Icons.person_outline
                      : Icons.person_off_outlined,
                  color: userController.selectedUser.value.active == 1
                      ? Colors.black
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
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  _deleteUser();
                },
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Telefon'),
                        initialValue:
                            userController.selectedUser.value.telephone,
                        onChanged: (value) =>
                            userController.selectedUser.value.telephone = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a telephone number';
                          }
                          return null;
                        },
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
                        ExpansionTile(
                          title: Text("Temel Yetkiler"),
                          children: claimController.operationClaims.map((c) {
                            return ListTile(
                              title: Text(c.name),
                              trailing: Checkbox(
                                onChanged: (value) {
                                  if (value!) {
                                    claimController
                                        .addUserClaim(UserOperationClaim(
                                      id: 0,
                                      userId:
                                          userController.selectedUser.value.id,
                                      operationClaimId: c.id,
                                    ));
                                  } else {
                                    var claim = userController
                                        .selectedUserClaims
                                        .firstWhereOrNull((uc) =>
                                            uc.operationClaimId == c.id);
                                    claimController.deleteUserClaim(
                                        claim != null ? claim.id : 0);
                                  }
                                },
                                value: userController.selectedUserClaims
                                    .any((uc) => uc.operationClaimId == c.id),
                              ),
                            );
                          }).toList(),
                        ),
                        Divider(),
                        ExpansionTile(
                          title: Text("Cihaz Yetkileri"),
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
