import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simird/models/doctor.dart';
import 'package:simird/models/patient.dart';
import 'package:simird/routes/app_routes.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String> getHomeRoute(String uid) async {
    // Verifica si el usuario es doctor o paciente
    DocumentSnapshot doctorDoc = await _firestore.collection('doctors').doc(uid).get();
    if (doctorDoc.exists) {
      return AppRoutes.doctorHome;
    } else {
      return AppRoutes.patientHome;
    }
  }


  // Iniciar sesión con correo y contraseña
  Future<void> signInWithEmailAndPassword(String email, String password, {BuildContext? context}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Obtiene la ruta correcta después del login
      if (userCredential.user != null) {
        String homeRoute = await getHomeRoute(userCredential.user!.uid);
        //Navegacion si el context esta presente
        if(context != null){
          Navigator.of(context).pushReplacementNamed(homeRoute);
        }

      }

    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e); // Usar la función de manejo de errores
    }
  }


  // Registrar un doctor
  Future<void> registerDoctor(String email, String password, String name, String exequatur, int age, {BuildContext? context}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Crea una instancia del modelo Doctor
        Doctor newDoctor = Doctor(
          uid: user.uid,
          name: name,
          email: email,
          exequatur: exequatur,
          age: age,
          specialty: '', // Se llenarán después
          consultationPlace: '', // Se llenarán después
          consultationPrice: 0,
        );
        // Guarda el doctor en Firestore
        await _firestore.collection('doctors').doc(user.uid).set(newDoctor.toMap());

        // Obtiene la ruta correcta después del registro
        String homeRoute = await getHomeRoute(user.uid);
        if(context != null){
          Navigator.of(context).pushReplacementNamed(homeRoute); // Navega a la pantalla principal del doctor
        }

      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }


  // Registrar un paciente
  Future<void> registerPatient(String email, String password, String name, int age, {BuildContext? context}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Crea una instancia del modelo Patient
        Patient newPatient = Patient(
          uid: user.uid,
          name: name,
          email: email,
          age: age,
        );

        // Guarda el paciente en Firestore
        await _firestore.collection('patients').doc(user.uid).set(newPatient.toMap());

        // Obtiene la ruta correcta después del registro
        String homeRoute = await getHomeRoute(user.uid);
        //Navegacion
        if(context != null){
          Navigator.of(context).pushReplacementNamed(homeRoute);
        }
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  //Cerrar sesion
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    await _googleSignIn.signOut(); // Cierra sesión de Google también
    Navigator.of(context).pushReplacementNamed(AppRoutes.auth); // Vuelve a la pantalla de autenticación
  }



  // Inicio de sesión con Google
  Future<void> signInWithGoogle({BuildContext? context}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // El usuario canceló el inicio de sesión

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Verifica si el usuario ya existe en Firestore (ya sea como doctor o paciente)
        DocumentSnapshot doctorDoc = await _firestore.collection('doctors').doc(user.uid).get();
        DocumentSnapshot patientDoc = await _firestore.collection('patients').doc(user.uid).get();

        if (!doctorDoc.exists && !patientDoc.exists) {
          // Si no existe, crea un nuevo paciente por defecto.  Podrías preguntar al usuario si es doctor.
          Patient newPatient = Patient(
            uid: user.uid,
            name: user.displayName ?? 'Usuario de Google', // Usa el nombre de Google, o un valor por defecto
            email: user.email!,  // El correo de Google siempre está presente
            age: 0, //  Podrías pedir la edad en un paso posterior.
          );

          await _firestore.collection('patients').doc(user.uid).set(newPatient.toMap());
        }
        //Obtener ruta
        String homeRoute = await getHomeRoute(user.uid);

        //Navegacion
        if(context != null){
          Navigator.of(context).pushReplacementNamed(homeRoute);
        }
      }


    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }


  // Funcion para controlar las excepciones
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró un usuario con ese correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo electrónico.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      default:
        return 'Ocurrió un error de autenticación: ${e.message}';
    }
  }
}