import 'package:flutter/material.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class AppDropdownField<T> extends StatelessWidget {
  final T? value;
  final String label;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isExpanded;

  const AppDropdownField({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    this.onChanged,
    this.validator,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
        isExpanded: isExpanded,
        style: const TextStyle(color: Colors.black, fontSize: 15),
        dropdownColor: Colors.white,
        iconEnabledColor: goldColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.brown[500]),
          floatingLabelStyle: TextStyle(
            color: goldColor,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(icon, color: Colors.brown[500]),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.brown.shade300, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: goldColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
