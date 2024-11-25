import 'package:akilli_anahtar/controllers/admin/user_management_control.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/pages/user_manager/user_operation_claim_list_view_widget.dart';
import 'package:akilli_anahtar/pages/user_manager/user_organisation_claim_widget.dart';
import 'package:akilli_anahtar/pages/user_manager/user_device_claim_widget.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class UserAddEditPage extends StatefulWidget {
  const UserAddEditPage({super.key});

  @override
  State<UserAddEditPage> createState() => _UserAddEditPageState();
}

class _UserAddEditPageState extends State<UserAddEditPage>
    with TickerProviderStateMixin
    implements VListener {
  late TabController tabController;
  UserManagementController userManagementControl =
      Get.put(UserManagementController());
  HomeController homeController = Get.find();
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  late String userName;
  late var userNameFocusNode = FocusNode();
  late String fullName;
  late var fullNameFocusNode = FocusNode();
  late String password;
  late var passwordFocusNode = FocusNode();
  late String mail;
  late var mailFocusNode = FocusNode();
  late String telephone;
  late var telephoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
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
          bottom: TabBar(
            indicatorColor: goldColor,
            labelColor: goldColor,
            overlayColor: WidgetStatePropertyAll(goldColor.withOpacity(0.2)),
            onTap: (value) {
              if (userManagementControl.selectedUser.value.id == 0) {
                value = 0;
              }
              tabController.index = value;
            },
            controller: tabController,
            tabs: [
              Tab(
                text: "Kullanıcı Bilgileri",
              ),
              Tab(
                text: "Yetkiler",
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          inputDecorationTheme: InputDecorationTheme(
                              labelStyle: TextStyle(color: goldColor),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: goldColor))),
                          textSelectionTheme: TextSelectionThemeData(
                            selectionHandleColor: goldColor,
                            selectionColor: goldColor,
                          ),
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              cursorColor: goldColor,
                              decoration:
                                  InputDecoration(labelText: 'Kullanıcı Adı'),
                              initialValue: userName,
                              onChanged: (value) => userName = value,
                              validator: (value) {
                                return validate(0, value);
                              },
                              focusNode: userNameFocusNode,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(fullNameFocusNode);
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              cursorColor: goldColor,
                              decoration:
                                  InputDecoration(labelText: 'Ad Soyad'),
                              initialValue: fullName,
                              onChanged: (value) => fullName = value,
                              validator: (value) {
                                return validate(1, value);
                              },
                              focusNode: fullNameFocusNode,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(passwordFocusNode);
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              cursorColor: goldColor,
                              decoration: InputDecoration(
                                labelText: 'Şifre',
                                // suffixIcon: userManagementControl
                                //             .selectedUser.value.id ==
                                //         0
                                //     ? null
                                //     : TextButton(
                                //         onPressed: () {
                                //           _saveUser(isValidate: false);
                                //         },
                                //         child: Text("Güncelle"),
                                //       ),
                              ),
                              initialValue: password,
                              onChanged: (value) => password = value,
                              validator: (value) {
                                return validate(4, value);
                              },
                              focusNode: passwordFocusNode,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(mailFocusNode);
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              cursorColor: goldColor,
                              decoration: InputDecoration(labelText: 'Email'),
                              initialValue: mail,
                              onChanged: (value) => mail = value,
                              validator: (value) {
                                return validate(2, value);
                              },
                              focusNode: mailFocusNode,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(telephoneFocusNode);
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              cursorColor: goldColor,
                              decoration: InputDecoration(labelText: 'Telefon'),
                              initialValue: telephone,
                              onChanged: (value) => telephone = value,
                              validator: (value) {
                                return validate(3, value);
                              },
                              focusNode: telephoneFocusNode,
                            ),
                            SizedBox(height: 8),
                            organisationSelect(),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: _saveUser,
                                  child: SizedBox(
                                    height: height(context) * 0.05,
                                    width: width(context) * 0.30,
                                    child: Card(
                                      elevation: 5,
                                      color: goldColor.withOpacity(0.7),
                                      child: Center(
                                        child: Text(
                                          "Kaydet",
                                          style: textTheme(context)
                                              .titleLarge!
                                              .copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (userManagementControl
                                        .selectedUser.value.id >
                                    0)
                                  TextButton(
                                    onPressed: _saveAsUser,
                                    child: Text(
                                      "Farklı Kaydet",
                                      style: textTheme(context)
                                          .titleMedium!
                                          .copyWith(
                                            color: goldColor,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: 16),
                UserOperationClaimListViewWidget(),
                Divider(),
                UserDeviceClaimWidget(),
                Divider(),
                UserOrganisationClaimWidget(),
              ],
            ),
          ],
        ),
      );
    });
  }

  @override
  String? validate(int formIndex, String? value) {
    if (value == null || value.isEmpty) {
      if (formIndex == 2 || formIndex == 3) return null;
      if (formIndex == 4 && userManagementControl.selectedUser.value.id > 0) {
        return null;
      }
      return "Boş Geçilemez";
    }
    if (formIndex == 0) {
      var userAny = userManagementControl.users.any((u) =>
          u.userName == value &&
          u.id != userManagementControl.selectedUser.value.id);
      if (userAny) {
        return "Daha Önce Kullanılmış";
      }
    }
    return null;
  }

  organisationSelect() {
    return DropdownSearch<Organisation>(
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          hintText: "Kurum Seç",
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
      ),
      items: (filter, loadProps) {
        return homeController.organisations;
      },
      selectedItem: homeController.organisations.firstWhereOrNull(
          (o) => o.id == homeController.selectedOrganisationId.value),
      itemAsString: (item) => item.name,
      onChanged: (value) {
        if (value != null) {
          //
        }
      },
      filterFn: (item, filter) {
        return item.name.toLowerCase().contains(filter.toLowerCase());
      },
      compareFn: (item1, item2) {
        return item1.id == item2.id;
      },
      dropdownBuilder: (context, selectedItem) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedItem != null ? selectedItem.name : "",
                style: TextStyle(
                    color: selectedItem != null ? Colors.black : Colors.grey),
              ),
            ),
            if (selectedItem != null)
              IconButton(
                padding: EdgeInsets.only(bottom: 10),
                icon: Icon(Icons.clear),
                onPressed: () {
                  //
                },
              ),
          ],
        );
      },
    );
  }
}

abstract class VListener {
  String? validate(int id, String value);
}
