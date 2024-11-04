import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class InputText extends StatefulWidget {
  final TextEditingController controller;
  final IconData prefixIconData;
  final bool isPassword;
  const InputText({
    super.key,
    required this.controller,
    required this.prefixIconData,
    this.isPassword = false,
  });

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  LoginController loginController = Get.find();
  bool passVisible = false;
  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      elevation: 10,
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Zorunlu Alan";
          }
          return null;
        },
        controller: widget.controller,
        obscureText: widget.isPassword && !passVisible,
        cursorColor: Colors.black,
        onChanged: (value) {
          if (widget.isPassword) {
            loginController.password.value = value;
          } else {
            loginController.userName.value = value;
          }
        },
        textInputAction:
            widget.isPassword ? TextInputAction.done : TextInputAction.next,
        focusNode: widget.isPassword
            ? loginController.passwordFocus
            : loginController.userNameFocus,
        onFieldSubmitted: (value) {
          if (!widget.isPassword) {
            loginController.passwordFocus.requestFocus();
          }
        },
        style: textTheme(context).titleLarge,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          prefixIcon: Icon(
            widget.prefixIconData,
            size: 20,
          ),
          hintText: widget.isPassword ? "Kullanıcı adı" : "Şifre",
          hintStyle:
              textTheme(context).titleMedium!.copyWith(color: Colors.grey),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    passVisible
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      passVisible = !passVisible;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
