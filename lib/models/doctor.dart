import 'package:simird/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor extends AppUser {
  final String exequatur;
  String specialty;
  String consultationPlace;
  double consultationPrice;


  Doctor({
    required String uid,
    required String name,
    required String email,
    required this.exequatur,
    required int age,
    required this.specialty,
    required this.consultationPlace,
    required this.consultationPrice,

  }) : super(uid: uid, name: name, email: email, age: age);

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'exequatur': exequatur,
      'age' : age,
      'specialty': specialty,
      'consultationPlace': consultationPlace,
      'consultationPrice': consultationPrice,
    };
  }

  // Método para crear un Doctor desde un DocumentSnapshot de Firestore
  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Doctor(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      exequatur: data['exequatur'] ?? '',
      age: data['age'] ?? 0,
      specialty: data['specialty'] ?? '',
      consultationPlace: data['consultationPlace'] ?? '',
      consultationPrice: (data['consultationPrice'] ?? 0).toDouble(), // Asegura que sea double
    );
  }
}