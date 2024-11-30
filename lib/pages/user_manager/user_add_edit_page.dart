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

  User user = User();

  final _formKey = GlobalKey<FormState>();

  late var userNameFocusNode = FocusNode();
  late var fullNameFocusNode = FocusNode();
  late var passwordFocusNode = FocusNode();
  late var mailFocusNode = FocusNode();
  late var telephoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    user = userManagementControl.selectedUser.value;
    if (user.id > 0) {
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

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      if (user.id == 0) {
        await userManagementControl.register(user);
      } else {
        await userManagementControl.updateUser(user);
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

  void _saveAsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user.fullName),
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
                _saveUser();
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
          title: Text(user.id == 0 ? 'Kullanıcı Ekle' : 'Kullanıcı Düzenle'),
          actions: [
            if (user.id > 0)
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
              if (user.id == 0) {
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
              padding: const EdgeInsets.all(20.0),
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
                            SizedBox(
                              height: height(context) * 0.01,
                            ),
                            textFormField(
                              context,
                              0,
                              labelText: 'Kullanıcı Adı',
                              initialValue: user.userName,
                              onChanged: (value) =>
                                  setState(() => user.userName = value),
                              focusNode: userNameFocusNode,
                              nextFocus: fullNameFocusNode,
                            ),
                            SizedBox(height: 8),
                            textFormField(
                              context,
                              1,
                              labelText: 'Ad Soyad',
                              initialValue: user.fullName,
                              onChanged: (value) =>
                                  setState(() => user.fullName = value),
                              focusNode: fullNameFocusNode,
                              nextFocus: passwordFocusNode,
                            ),
                            SizedBox(height: 8),
                            textFormField(
                              context,
                              2,
                              labelText: 'Şifre',
                              initialValue: user.password,
                              onChanged: (value) =>
                                  setState(() => user.password = value),
                              focusNode: passwordFocusNode,
                              nextFocus: mailFocusNode,
                              suffix: user.id == 0
                                  ? null
                                  : InkWell(
                                      onTap: () {
                                        userManagementControl.passUpdate(
                                            user.id, user.password);
                                      },
                                      child: Text(
                                        "Güncelle",
                                        style: textTheme(context)
                                            .titleSmall!
                                            .copyWith(color: goldColor),
                                      ),
                                    ),
                            ),
                            SizedBox(height: 8),
                            textFormField(
                              context,
                              3,
                              labelText: "E-mail",
                              initialValue: user.mail,
                              onChanged: (value) =>
                                  setState(() => user.mail = value),
                              focusNode: mailFocusNode,
                              nextFocus: telephoneFocusNode,
                            ),
                            SizedBox(height: 8),
                            textFormField(
                              context,
                              4,
                              labelText: 'Telefon',
                              initialValue: user.telephone,
                              onChanged: (value) =>
                                  setState(() => user.telephone = value),
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
                                    height: height(context) * 0.06,
                                    width: width(context) * 0.50,
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
                                    onPressed: _saveAsDialog,
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
                // TabBar(tabs: [
                //   Tab(text: "Cihazlar"),
                //   Tab(text: "Kurumlar"),
                // ]),
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

  Widget textFormField(
    BuildContext context,
    int formIndex, {
    String? labelText,
    String? initialValue,
    void Function(String)? onChanged,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    Widget? suffix,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme:
            TextSelectionThemeData(selectionHandleColor: goldColor),
      ),
      child: TextFormField(
        cursorColor: goldColor,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: goldColor),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: goldColor,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: goldColor,
            ),
          ),
          suffix: suffix,
        ),
        initialValue: initialValue,
        onChanged: onChanged,
        validator: (value) {
          return validate(formIndex, value);
        },
        focusNode: focusNode,
        textInputAction:
            nextFocus == null ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(nextFocus);
        },
      ),
    );
  }

  @override
  String? validate(int formIndex, String? value) {
    if (value == null || value.isEmpty) {
      if (formIndex == 2 && user.id > 0) {
        return null;
      }
      if (formIndex == 3 || formIndex == 4) return null;
      return "Boş Geçilemez";
    }
    if (formIndex == 0) {
      var userAny = userManagementControl.users
          .any((u) => u.userName == value && u.id != user.id);
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
          labelText: "Kurum Seç",
          labelStyle: TextStyle(color: goldColor),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: goldColor,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: goldColor,
            ),
          ),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
      ),
      items: (filter, loadProps) {
        return homeController.organisations;
      },
      selectedItem: userManagementControl.selectedUser.value.id > 0
          ? homeController.organisations.firstWhereOrNull((o) =>
              o.id == userManagementControl.selectedUser.value.organisationId)
          : null,
      itemAsString: (item) => item.name,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            user.organisationId = value.id;
            user.organisationName = value.name;
          });
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
                  color: selectedItem != null ? Colors.black : Colors.grey,
                ),
              ),
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
