abstract class AppUser {
  final String uid;
  final String name;
  final String email;
  final int age;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
  });

  // Método para convertir a mapa (para Firestore)
  Map<String, dynamic> toMap();
}