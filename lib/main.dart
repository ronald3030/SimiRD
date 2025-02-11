import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:simird/routes/app_routes.dart';
import 'package:simird/services/auth_service.dart';
import 'package:simird/services/firestore_service.dart';
import 'firebase_options.dart';
import 'package:simird/screens/home_screen.dart';
import 'package:simird/screens/auth_screen.dart';
import 'package:simird/screens/doctor_home_screen.dart';
import 'package:simird/screens/patient_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa firebase_auth


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIMIRD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.dark, //  <-  Se movió acá
        primaryColor: Colors.blue.shade900,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        textTheme: const TextTheme(
          displayLarge:
          TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 18.0, color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[800],
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
        ),
      ),
      home: StreamBuilder<User?>( // Especifica el tipo de StreamBuilder como User?
        stream: Provider.of<AuthService>(context, listen: false).authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              final authService = Provider.of<AuthService>(context, listen: false);
              return FutureBuilder<String>(
                future: authService.getHomeRoute((snapshot.data as User).uid), // Cast a User
                builder: (context, routeSnapshot) {
                  if (routeSnapshot.connectionState == ConnectionState.done) {
                    switch (routeSnapshot.data) {
                      case AppRoutes.doctorHome:
                        return const DoctorHomeScreen();
                      case AppRoutes.patientHome:
                        return const PatientHomeScreen();
                      default:
                        return const AuthScreen();
                    }
                  } else {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              );
            } else {
              return const AuthScreen();
            }
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}