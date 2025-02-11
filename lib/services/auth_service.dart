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

  /// ✅ Iniciar sesión con Google (Método FALTANTE agregado)
  Future<void> signInWithGoogle({BuildContext? context}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> doctorDoc =
        await _firestore.collection('doctors').doc(user.uid).get();
        DocumentSnapshot<Map<String, dynamic>> patientDoc =
        await _firestore.collection('patients').doc(user.uid).get();

        if (!doctorDoc.exists && !patientDoc.exists) {
          Patient newPatient = Patient(
            uid: user.uid,
            name: user.displayName ?? 'Usuario de Google',
            email: user.email!,
            age: 0,
          );
          await _firestore.collection('patients').doc(user.uid).set(newPatient.toMap());
        }

        String homeRoute = await getHomeRoute(user.uid);
        if (context != null) {
          Navigator.of(context).pushReplacementNamed(homeRoute);
        }
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// ✅ Cerrar sesión (Método FALTANTE agregado)
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
  }

  /// ✅ Obtener la ruta del usuario después de iniciar sesión
  Future<String> getHomeRoute(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doctorDoc =
      await _firestore.collection('doctors').doc(uid).get();
      DocumentSnapshot<Map<String, dynamic>> patientDoc =
      await _firestore.collection('patients').doc(uid).get();

      if (doctorDoc.exists && doctorDoc.data() != null) {
        return AppRoutes.doctorHome;
      } else if (patientDoc.exists && patientDoc.data() != null) {
        return AppRoutes.patientHome;
      } else {
        return AppRoutes.auth; // Si el usuario no existe
      }
    } catch (e) {
      print("Error en getHomeRoute: $e");
      return AppRoutes.auth;
    }
  }

  /// ✅ Manejo de errores
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
