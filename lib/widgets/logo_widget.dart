import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', // O tu logo
      height: 120,
    );
  }
}