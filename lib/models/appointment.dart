import 'package:cloud_firestore/cloud_firestore.dart'; // <-- ¡IMPORTANTE! Agrega esta línea

// Modelo para las citas (puedes expandirlo)
class Appointment {
  final String doctorId;
  final String patientId;
  final DateTime date;
  final String description;
  final bool insuranceAccepted;

  Appointment({
    required this.doctorId,
    required this.patientId,
    required this.date,
    required this.description,
    required this.insuranceAccepted,
  });

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'date': date, // Firestore maneja bien los DateTime
      'description': description,
      'insuranceAccepted': insuranceAccepted,
    };
  }
  // fromFirestore para Appointment
  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Appointment(
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      date: (data['date'] as Timestamp).toDate(), // Convierte Timestamp a DateTime
      description: data['description'] ?? '',
      insuranceAccepted: data['insuranceAccepted'] ?? false,
    );
  }
}