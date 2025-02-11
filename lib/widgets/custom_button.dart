import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color; // Color opcional

  const CustomButton({Key? key, required this.text, required this.onPressed, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).primaryColor, // Usa color o el color primario del tema
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}