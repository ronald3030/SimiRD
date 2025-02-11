import 'package:flutter/material.dart';
import 'package:simird/routes/app_routes.dart';
import 'package:simird/widgets/custom_button.dart';
import 'package:simird/widgets/gradient_background.dart';
import 'package:simird/widgets/logo_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LogoWidget(),
              const SizedBox(height: 20),
              Text(
                'Bienvenido a SIMIRD',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Tu sistema inteligente de gestión médica',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Ingresar',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.auth);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}