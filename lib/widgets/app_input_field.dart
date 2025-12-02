import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';

class AppInputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputAction inputAction;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final FocusNode? nextFocus;
  final Widget? suffixIcon;

  const AppInputField({
    super.key,
    required this.controller,
    required this.icon,
    required this.label,
    this.obscure = false,
    this.validator,
    this.inputAction = TextInputAction.done,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.nextFocus,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextSelectionTheme(
        data: TextSelectionThemeData(
          selectionHandleColor: goldColor,
          selectionColor: goldColor.withOpacity(0.30),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          cursorColor: goldColor,
          mouseCursor: SystemMouseCursors.text,
          focusNode: focusNode,
          textInputAction:
              nextFocus != null ? TextInputAction.next : inputAction,
          onFieldSubmitted: (_) => nextFocus?.requestFocus(),
          validator: validator ??
              (value) => value == null || value.isEmpty
                  ? "Bu alan boş bırakılamaz"
                  : null,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.brown[500]),
            floatingLabelStyle: TextStyle(
              color: goldColor,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(icon, color: Colors.brown[500]),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.brown.shade400, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: goldColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.8),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }
}
