import 'package:akilli_anahtar/controllers/admin/user_management_control.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/dtos/user_dto.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/utils/validate_listener.dart';
import 'package:akilli_anahtar/widgets/organisation_select_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserAddEditForm extends StatefulWidget {
  const UserAddEditForm({super.key});

  @override
  State<UserAddEditForm> createState() => _UserAddEditFormState();
}

class _UserAddEditFormState extends State<UserAddEditForm>
    implements ValidateListener {
  late UserDto tempUser;
  UserManagementController userManagementControl =
      Get.put(UserManagementController());
  HomeController homeController = Get.find();

  final _formKey = GlobalKey<FormState>();

  late var userNameFocusNode = FocusNode();
  late var fullNameFocusNode = FocusNode();
  late var passwordController = TextEditingController();
  late var passwordFocusNode = FocusNode();
  late var mailFocusNode = FocusNode();
  late var telephoneFocusNode = FocusNode();

  late var actions = <String>["save", "update", "saveAs"];

  late var action = "save";

  bool organisationError = false;

  @override
  void initState() {
    super.initState();
    print("UserAddEditForm");
    tempUser = userManagementControl.umSelectedUser.value.copyWith();
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
                      initialValue:
                          userManagementControl.umSelectedUser.value.userName,
                      onChanged: (value) => setState(() => userManagementControl
                          .umSelectedUser.value.userName = value),
                      focusNode: userNameFocusNode,
                      nextFocus: fullNameFocusNode,
                    ),
                    SizedBox(height: 8),
                    textFormField(
                      context,
                      1,
                      labelText: 'Ad Soyad',
                      initialValue:
                          userManagementControl.umSelectedUser.value.fullName,
                      onChanged: (value) => setState(() => userManagementControl
                          .umSelectedUser.value.fullName = value),
                      focusNode: fullNameFocusNode,
                      nextFocus: passwordFocusNode,
                    ),
                    SizedBox(height: 8),
                    textFormField(
                      context,
                      2,
                      controller: passwordController,
                      labelText: 'Şifre',
                      onChanged: (value) => setState(() => userManagementControl
                          .umSelectedUser.value.password = value),
                      focusNode: passwordFocusNode,
                      nextFocus: mailFocusNode,
                    ),
                    SizedBox(height: 8),
                    textFormField(
                      context,
                      3,
                      labelText: "E-mail",
                      initialValue:
                          userManagementControl.umSelectedUser.value.mail,
                      onChanged: (value) => setState(() => userManagementControl
                          .umSelectedUser.value.mail = value),
                      focusNode: mailFocusNode,
                      nextFocus: telephoneFocusNode,
                    ),
                    SizedBox(height: 8),
                    textFormField(
                      context,
                      4,
                      labelText: 'Telefon',
                      initialValue:
                          userManagementControl.umSelectedUser.value.telephone,
                      onChanged: (value) => setState(() => userManagementControl
                          .umSelectedUser.value.telephone = value),
                      focusNode: telephoneFocusNode,
                    ),
                    SizedBox(height: 8),
                    OrganisationSelectWidget(
                      list: userManagementControl.organisationList,
                      selectedId: userManagementControl
                              .umSelectedUser.value.organisationId ??
                          0,
                      onChanged: (id) {
                        userManagementControl.umSelectedUser.value
                            .organisationId = id == 0 ? null : id;
                        userManagementControl
                                .umSelectedUser.value.organisationName =
                            id == 0
                                ? null
                                : userManagementControl.organisationList
                                    .singleWhere((o) => o.id == id)
                                    .name;
                      },
                      validator: (value) {
                        return validate(5, value?.name);
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
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
                          onTap: () async {
                            setState(() {
                              action = userManagementControl
                                          .umSelectedUser.value.id ==
                                      null
                                  ? actions[0]
                                  : actions[1];
                            });
                            if (_formKey.currentState!.validate()) {
                              if (userManagementControl
                                      .umSelectedUser.value.id ==
                                  null) {
                                userManagementControl.umSelectedUser.value.id =
                                    await userManagementControl.register(
                                        userManagementControl
                                            .umSelectedUser.value);
                              } else {
                                if (userManagementControl
                                        .umSelectedUser.value !=
                                    tempUser) {
                                  await userManagementControl.updateUser(
                                      userManagementControl
                                          .umSelectedUser.value);
                                } else {
                                  infoSnackbar("Bilgilendirme",
                                      "Hiçbir değişiklik yapılmadı");
                                }
                              }
                            }
                          },
                        ),
                        if (userManagementControl.umSelectedUser.value.id !=
                            null)
                          TextButton(
                            child: Text(
                              "Farklı Kaydet",
                              style: textTheme(context).titleMedium!.copyWith(
                                    color: goldColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                            onPressed: () async {
                              setState(() {
                                action = actions[2];
                              });
                              if (_formKey.currentState!.validate()) {
                                userManagementControl.umSelectedUser.value.id =
                                    await userManagementControl.register(
                                        userManagementControl
                                            .umSelectedUser.value);
                              }
                            },
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
      if (formIndex == 5) return "Kurum seçimi zorunlu";
      if (action == actions[0] || action == actions[2]) {
        if (formIndex == 2) return "Şifre boş olamaz";
      }
    } else {
      if (formIndex == 0) {
        int? id = action == actions[2]
            ? 0
            : userManagementControl.umSelectedUser.value.id;
        var userAny = userManagementControl.users
            .any((u) => u.userName == value && u.id != id);
        if (userAny) {
          if (action == actions[0] || action == actions[2]) {
            return "Daha Önce Kullanılmış";
          }
        }
      }
    }
    return null;
  }
}
