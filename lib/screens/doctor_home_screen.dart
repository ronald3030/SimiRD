import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simird/services/auth_service.dart';
import 'package:simird/services/firestore_service.dart';
import 'package:simird/models/doctor.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _specialtyController = TextEditingController();
  final _consultationPlaceController = TextEditingController();
  final _consultationPriceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _specialtyController.dispose();
    _consultationPlaceController.dispose();
    _consultationPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false); // Obtiene FirestoreService
    final user = authService.authStateChanges.first; // Obtiene el usuario actual

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio Doctor'),
        actions: [
          IconButton(
            onPressed: () => authService.signOut(context), // Cierra sesión
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<Doctor?>( // Usa FutureBuilder para obtener los datos del doctor
        future: user.then((user) => firestoreService.getDoctor(user!.uid)), // Obtiene los datos del doctor
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Doctor doctor = snapshot.data!;
            // Actualiza los controladores con los datos existentes
            _specialtyController.text = doctor.specialty;
            _consultationPlaceController.text = doctor.consultationPlace;
            _consultationPriceController.text = doctor.consultationPrice.toString();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(  // Usa ListView para permitir scroll si el contenido es largo
                  children: [
                    TextFormField(
                      controller: _specialtyController,
                      decoration: const InputDecoration(labelText: 'Especialidad'),
                      validator: (value) => value!.isEmpty ? 'Por favor, ingresa tu especialidad' : null,
                    ),
                    TextFormField(
                      controller: _consultationPlaceController,
                      decoration: const InputDecoration(labelText: 'Lugar de Consulta'),
                      validator: (value) => value!.isEmpty ? 'Por favor, ingresa el lugar de consulta' : null,
                    ),
                    TextFormField(
                      controller: _consultationPriceController,
                      decoration: const InputDecoration(labelText: 'Precio de Consulta'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, ingresa el precio de consulta';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor, ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _isLoading ? const CircularProgressIndicator() :  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true; // Inicia la indicación de carga
                          });
                          // Actualiza la información del doctor
                          doctor.specialty = _specialtyController.text;
                          doctor.consultationPlace = _consultationPlaceController.text;
                          doctor.consultationPrice = double.parse(_consultationPriceController.text);

                          // Llama a FirestoreService para actualizar la información
                          await firestoreService.updateDoctorData(doctor);
                          setState(() {
                            _isLoading = false; // Finaliza la indicación de carga
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Datos actualizados correctamente!'))
                          );

                        }
                      },
                      child: const Text('Guardar Cambios'),
                    ),
                  ],
                ),
              ),
            );

          }else{
            return const Center(child: Text('No se encontraron datos del doctor.'));
          }
        },
      ),
    );
  }
}