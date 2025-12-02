import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final Icon icon;
  final bool isPassword;
  final String? hintText;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final bool autoFocus;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.icon,
    this.hintText,
    required this.focusNode,
    this.nextFocus,
    this.isPassword = false,
    this.autoFocus = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool passVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && !passVisible,
      focusNode: widget.focusNode,
      autofocus: widget.autoFocus,
      onSubmitted: (_) {
        if (widget.nextFocus != null) {
          FocusScope.of(context).requestFocus(widget.nextFocus);
        }
      },
      textInputAction: widget.nextFocus != null
          ? TextInputAction.next
          : TextInputAction.done,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: widget.icon,
        filled: true,
        fillColor: Colors.brown[50],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.brown, width: 1.5),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    passVisible = !passVisible;
                  });
                },
                icon: Icon(
                  passVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[700],
                ),
              )
            : null,
      ),
    );
  }
}
