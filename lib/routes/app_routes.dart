import 'package:flutter/material.dart';
import 'package:simird/screens/auth_screen.dart';
import 'package:simird/screens/doctor_home_screen.dart';
import 'package:simird/screens/patient_home_screen.dart';
import 'package:simird/screens/home_screen.dart';

class AppRoutes {
  static const String initialRoute = '/'; // Pantalla de inicio (Home)
  static const String auth = '/auth';
  static const String doctorHome = '/doctorHome';
  static const String patientHome = '/patientHome';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen()); // Ruta inicial
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case doctorHome:
        return MaterialPageRoute(builder: (_) => const DoctorHomeScreen());
      case patientHome:
        return MaterialPageRoute(builder: (_) => const PatientHomeScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                  child: Text('No route defined for ${settings.name}')),
            ));
    }
  }
}