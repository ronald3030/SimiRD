import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simird/models/doctor.dart';
import 'package:simird/models/patient.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Obtener un doctor por su UID
  Future<Doctor?> getDoctor(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
      await _firestore.collection('doctors').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return Doctor.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Error al obtener el doctor: $e");
      return null;
    }
  }

  /// ✅ Obtener un paciente por su UID
  Future<Patient?> getPatient(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
      await _firestore.collection('patients').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return Patient.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Error al obtener el paciente: $e");
      return null;
    }
  }

  /// ✅ Actualizar datos de un doctor (Método FALTANTE agregado)
  Future<void> updateDoctorData(Doctor doctor) async {
    try {
      await _firestore.collection('doctors').doc(doctor.uid).update(doctor.toMap());
    } catch (e) {
      print("Error al actualizar datos del doctor: $e");
      rethrow;
    }
  }

  /// ✅ Buscar doctores por especialidad y/o provincia (Método FALTANTE agregado)
  Future<List<Doctor>> searchDoctors({String? specialty, String? province}) async {
    try {
      Query query = _firestore.collection('doctors');

      if (specialty != null && specialty.isNotEmpty) {
        query = query.where('specialty', isEqualTo: specialty);
      }
      if (province != null && province.isNotEmpty) {
        query = query.where('consultationPlace', isEqualTo: province);
      }

      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error al buscar doctores: $e");
      rethrow;
    }
  }
}
