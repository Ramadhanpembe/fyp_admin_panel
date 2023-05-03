import 'package:flutter/material.dart';

class FormTextField extends StatelessWidget {
  const FormTextField(
      {super.key,
      required this.hintText,
      required this.label,
      this.obscureText = false,
      this.keyboardType = TextInputType.text,
      this.validator,
      this.controller});

  final String hintText;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: TextFormField(
        validator: validator,
        controller: controller,
        obscureText: obscureText,
        enableSuggestions: false,
        autocorrect: false,
        style: const TextStyle(
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
          decorationThickness: 0.0,
        ),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          label: Text(label),
          hintText: hintText,
          border: const OutlineInputBorder(),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
