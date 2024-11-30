import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPageFormInputText extends StatefulWidget {
  final TextEditingController controller;
  final bool isPassword;
  final String? hintText;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final String? Function(String? value)? validator;
  const LoginPageFormInputText({
    super.key,
    required this.controller,
    this.isPassword = false,
    this.hintText,
    required this.focusNode,
    this.nextFocusNode,
    this.validator,
  });

  @override
  State<LoginPageFormInputText> createState() => _LoginPageFormInputTextState();
}

class _LoginPageFormInputTextState extends State<LoginPageFormInputText> {
  bool passVisible = false;
  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      elevation: 10,
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme:
              TextSelectionThemeData(selectionHandleColor: goldColor),
        ),
        child: TextFormField(
          validator: widget.validator,
          controller: widget.controller,
          obscureText: widget.isPassword && !passVisible,
          cursorColor: Colors.black,
          textInputAction: widget.nextFocusNode == null
              ? TextInputAction.done
              : TextInputAction.next,
          focusNode: widget.focusNode,
          onFieldSubmitted: (value) {
            if (widget.nextFocusNode != null) {
              widget.nextFocusNode!.requestFocus();
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
            hintText: widget.hintText,
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
