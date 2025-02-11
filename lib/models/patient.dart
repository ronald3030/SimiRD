import 'package:simird/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Patient extends AppUser {
  Patient({
    required String uid,
    required String name,
    required String email,
    required int age,
  }) : super(uid: uid, name: name, email: email, age: age);

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
    };
  }
  // Método para crear un Patient desde un DocumentSnapshot de Firestore
  factory Patient.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Patient(
        uid: doc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
      age: data['age'] ?? 0,
    );
  }
}