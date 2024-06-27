import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final Icon icon;
  final bool isPassword;
  final String? hintText;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  const CustomTextField(
      {Key? key,
      required this.controller,
      required this.icon,
      this.hintText,
      required this.focusNode,
      this.nextFocus,
      this.isPassword = false})
      : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  var iconColor;
  @override
  void initState() {
    super.initState();
  }

  bool passVisible = false;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && !passVisible,
      focusNode: widget.focusNode,
      cursorColor: Colors.white,
      onSubmitted: (value) {
        if (widget.nextFocus != null) {
          widget.nextFocus!.requestFocus();
        }
      },
      textInputAction: widget.nextFocus != null
          ? TextInputAction.next
          : TextInputAction.done,
      style: TextStyle(
          fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
          fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
        ),
        prefixIcon: widget.icon,
        prefixIconColor:
            widget.focusNode.hasFocus ? Colors.white : Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          borderSide: BorderSide(
            width: 1,
            color: Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          borderSide: BorderSide(
            width: 1,
            color: Colors.white,
          ),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    passVisible = !passVisible;
                  });
                },
                icon: Icon(Icons.visibility,
                    color: passVisible ? Colors.white : Colors.black54),
              )
            : null,
      ),
    );
  }
}
