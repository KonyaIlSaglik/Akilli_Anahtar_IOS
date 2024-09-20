import 'package:akilli_anahtar/controllers/claim_controller.dart';
import 'package:akilli_anahtar/controllers/user_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/entities/user_device.dart';
import 'package:akilli_anahtar/entities/user_operation_claim.dart';
import 'package:akilli_anahtar/models/register_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turkish/turkish.dart';

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
      claimController.getOrganisations();
      claimController.getBoxes();
      claimController.getRelays();
      claimController.getSensors();
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
                        ExpansionTile(
                          title: Text("Temel Yetkiler"),
                          children: claimController.operationClaims.map((c) {
                            return ListTile(
                              title: Text(c.name),
                              trailing: Checkbox(
                                onChanged: (value) async {
                                  if (value != null) {
                                    if (value) {
                                      var addedClaim = await claimController
                                          .addUserClaim(UserOperationClaim(
                                        id: 0,
                                        userId: userController
                                            .selectedUser.value.id,
                                        operationClaimId: c.id,
                                      ));
                                      if (addedClaim != null) {
                                        userController.selectedUserClaims
                                            .add(addedClaim);
                                      }
                                    } else {
                                      var claim = userController
                                          .selectedUserClaims
                                          .firstWhere((uc) =>
                                              uc.operationClaimId == c.id);
                                      var isDeleted = await claimController
                                          .deleteUserClaim(claim.id);
                                      if (isDeleted) {
                                        userController.selectedUserClaims
                                            .remove(claim);
                                      }
                                    }
                                  }
                                },
                                value: userController.selectedUserClaims
                                    .any((uc) => uc.operationClaimId == c.id),
                              ),
                            );
                          }).toList(),
                        ),
                        Divider(),
                        ListTile(
                          title: Text("Cihaz Yetkileri"),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.95,
                                  width: MediaQuery.of(context).size.width,
                                  child: AlertDialog(
                                    content: Column(
                                      children: [
                                        claimController.organisations.isEmpty
                                            ? CircularProgressIndicator()
                                            : DropdownSearch<Organisation>(
                                                dropdownDecoratorProps:
                                                    DropDownDecoratorProps(
                                                        dropdownSearchDecoration:
                                                            InputDecoration(
                                                  hintText: "Kurum Seç",
                                                  border: OutlineInputBorder(),
                                                )),
                                                popupProps: PopupProps.menu(
                                                  showSearchBox: true,
                                                ),
                                                items: claimController
                                                    .organisations,
                                                selectedItem: claimController
                                                    .organisations
                                                    .firstWhereOrNull((o) =>
                                                        o.id ==
                                                        claimController
                                                            .selectedOrganisationId
                                                            .value),
                                                itemAsString: (item) =>
                                                    item.name,
                                                onChanged: (value) {
                                                  setState(() {
                                                    claimController
                                                        .selectedOrganisationId
                                                        .value = value!.id;
                                                    claimController
                                                        .filterBoxes();
                                                  });
                                                },
                                                filterFn: (item, filter) {
                                                  return item.name
                                                      .toLowerCaseTr()
                                                      .contains(filter
                                                          .toLowerCaseTr());
                                                },
                                              ),
                                        SizedBox(height: 8),
                                        claimController.boxes.isEmpty
                                            ? CircularProgressIndicator()
                                            : DropdownSearch<Box>(
                                                popupProps: PopupProps.menu(
                                                  showSearchBox: true,
                                                ),
                                                items: claimController
                                                    .filteredBoxes,
                                                selectedItem: claimController
                                                    .filteredBoxes
                                                    .firstWhereOrNull((o) =>
                                                        o.id ==
                                                        claimController
                                                            .selectedBoxId
                                                            .value),
                                                itemAsString: (item) =>
                                                    item.name,
                                                onChanged: (value) {
                                                  setState(() {
                                                    claimController
                                                        .selectedBoxId
                                                        .value = value!.id;
                                                  });
                                                },
                                                filterFn: (item, filter) {
                                                  return item.name
                                                      .toLowerCaseTr()
                                                      .contains(filter
                                                          .toLowerCaseTr());
                                                },
                                              ),
                                        SizedBox(height: 8),
                                        Expanded(
                                          child: DefaultTabController(
                                            initialIndex: 0,
                                            length: 2,
                                            child: Scaffold(
                                              appBar: AppBar(
                                                toolbarHeight: 0,
                                                automaticallyImplyLeading:
                                                    false,
                                                bottom: const TabBar(
                                                  tabs: <Widget>[
                                                    Tab(
                                                      text: "Röleler",
                                                    ),
                                                    Tab(
                                                      text: "Sensörler",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              body: TabBarView(
                                                children: <Widget>[
                                                  ListView.separated(
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ListTile(
                                                        title: Text(
                                                            claimController
                                                                .relays[index]
                                                                .name),
                                                        trailing: Checkbox(
                                                          onChanged:
                                                              (value) async {
                                                            if (value != null) {
                                                              if (value) {
                                                                var addedUserDevice =
                                                                    await claimController
                                                                        .addUserDevice(
                                                                  UserDevice(
                                                                    id: 0,
                                                                    userId: userController
                                                                        .selectedUser
                                                                        .value
                                                                        .id,
                                                                    boxId: claimController
                                                                        .relays[
                                                                            index]
                                                                        .boxId,
                                                                    deviceId: claimController
                                                                        .relays[
                                                                            index]
                                                                        .id,
                                                                    deviceTypeId: claimController
                                                                        .relays[
                                                                            index]
                                                                        .deviceTypeId,
                                                                  ),
                                                                );
                                                                if (addedUserDevice !=
                                                                    null) {
                                                                  claimController
                                                                      .userDevices
                                                                      .add(
                                                                          addedUserDevice);
                                                                }
                                                              } else {
                                                                var userDevice = claimController.userDevices.firstWhere((ud) =>
                                                                    ud.deviceId ==
                                                                        claimController
                                                                            .relays[
                                                                                index]
                                                                            .id &&
                                                                    ud.deviceTypeId ==
                                                                        claimController
                                                                            .relays[index]
                                                                            .deviceTypeId);
                                                                var isDeleted =
                                                                    await claimController
                                                                        .deleteUserDevice(
                                                                            userDevice.id);
                                                                if (isDeleted) {
                                                                  claimController
                                                                      .userDevices
                                                                      .remove(
                                                                          userDevice);
                                                                }
                                                              }
                                                            }
                                                          },
                                                          value: claimController.userDevices.any((ud) =>
                                                              ud.deviceId ==
                                                                  claimController
                                                                      .relays[
                                                                          index]
                                                                      .id &&
                                                              ud.deviceTypeId ==
                                                                  claimController
                                                                      .relays[
                                                                          index]
                                                                      .deviceTypeId),
                                                        ),
                                                      );
                                                    },
                                                    separatorBuilder:
                                                        (context, index) {
                                                      return Divider();
                                                    },
                                                    itemCount: claimController
                                                        .relays.length,
                                                  ),
                                                  Center(
                                                    child:
                                                        Text("It's rainy here"),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text("Kapat"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
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
