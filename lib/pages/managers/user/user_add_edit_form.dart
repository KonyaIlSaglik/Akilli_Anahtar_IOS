import 'package:akilli_anahtar/controllers/admin/user_management_control.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/dtos/um_organisation_dto.dart';
import 'package:akilli_anahtar/dtos/user_dto.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/utils/validate_listener.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserAddEditForm extends StatefulWidget {
  const UserAddEditForm({super.key});

  @override
  State<UserAddEditForm> createState() => _UserAddEditFormState();
}

class _UserAddEditFormState extends State<UserAddEditForm>
    implements ValidateListener {
  UserManagementController userManagementControl =
      Get.put(UserManagementController());
  HomeController homeController = Get.find();
  UserDto user = UserDto();

  final _formKey = GlobalKey<FormState>();

  late var userNameFocusNode = FocusNode();
  late var fullNameFocusNode = FocusNode();
  late var passwordController = TextEditingController();
  late var passwordFocusNode = FocusNode();
  late var mailFocusNode = FocusNode();
  late var telephoneFocusNode = FocusNode();

  late var actions = <String>["save", "saveAs", "update", "passUpdate"];

  late var action = "save";

  @override
  void initState() {
    super.initState();
    print("UserAddEditForm");
    user = userManagementControl.selectedUser.value.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                      controller: passwordController,
                      labelText: 'Şifre',
                      onChanged: (value) =>
                          setState(() => user.password = value),
                      focusNode: passwordFocusNode,
                      nextFocus: mailFocusNode,
                      suffix: user.id == 0
                          ? null
                          : InkWell(
                              onTap: () async {
                                setState(() {
                                  action = actions[3];
                                });
                                if (_formKey.currentState!.validate()) {
                                  await userManagementControl.passUpdate(
                                      user.id, passwordController.text);
                                  passwordController.text = "";
                                }
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
                      onChanged: (value) => setState(() => user.mail = value),
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
                          onTap: () {
                            setState(() {
                              action = user.id == 0 ? actions[0] : actions[2];
                            });
                            _saveUser();
                          },
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
                        if (userManagementControl.selectedUser.value.id > 0)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                action = actions[1];
                              });
                              _saveAsDialog();
                            },
                            child: Text(
                              "Farklı Kaydet",
                              style: textTheme(context).titleMedium!.copyWith(
                                    color: goldColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
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
    );
  }

  Widget textFormField(
    BuildContext context,
    int formIndex, {
    TextEditingController? controller,
    String? labelText,
    String? initialValue,
    void Function(String)? onChanged,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    Widget? suffix,
  }) {
    return SizedBox(
      height: height(context) * 0.07,
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme:
              TextSelectionThemeData(selectionHandleColor: goldColor),
        ),
        child: TextFormField(
          controller: controller,
          cursorColor: goldColor,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle:
                textTheme(context).labelMedium!.copyWith(color: goldColor),
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
          style: textTheme(context).titleSmall,
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
      ),
    );
  }

  @override
  String? validate(int formIndex, String? value) {
    //late var actions = <String>["save", "saveAs", "update", "passUpdate"];
    print("$formIndex : $value");
    if (value == null || value.isEmpty) {
      if (formIndex == 0) return "Kulanıcı adı boş olamaz";
      if (formIndex == 1) return "Ad soyad boş olamaz";
      if (formIndex == 3 || formIndex == 4) return null;
      if (formIndex == 2) {
        if (action != actions[2]) {
          return "Şifre boş olamaz";
        }
      }
    } else {
      if (formIndex == 0) {
        var userAny =
            userManagementControl.users.any((u) => u.userName == value);
        if (userAny) {
          if (action == actions[0] || action == actions[1]) {
            return "Daha Önce Kullanılmış";
          }
        }
      }
    }
    return null;
  }

  organisationSelect() {
    return DropdownSearch<UmOrganisationDto>(
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
        return userManagementControl.umOrganisations;
      },
      selectedItem: userManagementControl.selectedUser.value.id > 0
          ? userManagementControl.umOrganisations.firstWhereOrNull((o) =>
              o.id == userManagementControl.selectedUser.value.organisationId)
          : null,
      itemAsString: (item) => item.name!,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            user.organisationId = value.id!;
            user.organisationName = value.name!;
          });
        }
      },
      filterFn: (item, filter) {
        return item.name!.toLowerCase().contains(filter.toLowerCase());
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
                selectedItem != null ? selectedItem.name! : "",
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

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      if (user.id == 0) {
        user = await userManagementControl.register(user) ?? UserDto();
        setState(() {
          passwordController.text = "";
        });
      } else {
        if (action == actions[1]) {
          user = await userManagementControl.register(user) ?? UserDto();
        }
        if (user ==
            userManagementControl.users.singleWhere(
              (u) => u.id == user.id,
            )) {
          infoSnackbar("Bilgilendirme", "Hiç bir değişiklik yapılmadı");
        } else {
          await userManagementControl.updateUser(user);
          setState(() {
            passwordController.text = "";
          });
        }
      }
    }
  }

  void _saveAsDialog() {
    if (_formKey.currentState!.validate()) {
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
                child: Text("Kaydet"),
                onPressed: () async {
                  _saveUser();
                  Get.back();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
