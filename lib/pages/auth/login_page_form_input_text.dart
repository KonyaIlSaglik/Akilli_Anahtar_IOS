import 'package:akilli_anahtar/controllers/login_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class LoginPageFormInputText extends StatefulWidget {
  final TextEditingController controller;
  final bool isPassword;
  const LoginPageFormInputText({
    super.key,
    required this.controller,
    this.isPassword = false,
  });

  @override
  State<LoginPageFormInputText> createState() => _LoginPageFormInputTextState();
}

class _LoginPageFormInputTextState extends State<LoginPageFormInputText> {
  LoginController loginController = Get.find();
  bool passVisible = false;
  @override
  Widget build(BuildContext context) {
    widget.controller.text = widget.isPassword ? "Mehmet" : "mehmet";
    return Card.outlined(
      elevation: 10,
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme:
              TextSelectionThemeData(selectionHandleColor: goldColor),
        ),
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
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(
              widget.isPassword
                  ? FontAwesomeIcons.key
                  : FontAwesomeIcons.solidUser,
              size: 20,
              color: goldColor,
            ),
            hintText: !widget.isPassword ? "Kullanıcı adı" : "Şifre",
            hintStyle:
                textTheme(context).titleMedium!.copyWith(color: Colors.grey),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      passVisible
                          ? FontAwesomeIcons.eyeSlash
                          : FontAwesomeIcons.eye,
                      size: 20,
                      color: goldColor,
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
      ),
    );
  }
}
