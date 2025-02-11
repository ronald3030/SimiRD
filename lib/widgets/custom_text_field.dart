import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType; // Agrega keyboardType
  final Widget? prefixIcon;

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType, // Usa keyboardType aquí
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon, // Usa prefixIcon
      ),
    );
  }
}