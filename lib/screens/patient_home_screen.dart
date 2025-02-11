import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simird/services/auth_service.dart';
import 'package:simird/services/firestore_service.dart';
import 'package:simird/models/doctor.dart'; // Importa el modelo Doctor


class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({Key? key}) : super(key: key);

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  String _selectedSpecialty = ''; // Estado para la especialidad seleccionada
  String _selectedProvince = '';    // Estado para la provincia seleccionada
  List<Doctor> _doctors = [];       // Lista para almacenar los doctores filtrados
  bool _isLoading = false;

  final _specialties = [
    'Cardiología', 'Dermatología', 'Endocrinología', 'Gastroenterología',
    'Medicina General', 'Neurología', 'Oftalmología', 'Pediatría', 'Psiquiatría',
    'Otra'
  ];
// Lista de provincias (puedes ajustarla)
  final _provinces = [
    'Azua', 'Bahoruco', 'Barahona', 'Dajabón', 'Distrito Nacional', 'Duarte',
    'Elías Piña', 'El Seibo', 'Espaillat', 'Hato Mayor', 'Hermanas Mirabal',
    'Independencia', 'La Altagracia', 'La Romana', 'La Vega', 'María Trinidad Sánchez',
    'Monseñor Nouel', 'Monte Cristi', 'Monte Plata', 'Pedernales', 'Peravia',
    'Puerto Plata', 'Samaná', 'San Cristóbal', 'San José de Ocoa', 'San Juan',
    'San Pedro de Macorís', 'Sánchez Ramírez', 'Santiago', 'Santiago Rodríguez',
    'Santo Domingo', 'Valverde'
  ];

  // Método para buscar doctores
  Future<void> _searchDoctors(FirestoreService firestoreService) async {
    setState(() {
      _isLoading = true;
    });
    try{
      _doctors = await firestoreService.searchDoctors(
        specialty: _selectedSpecialty,
        province: _selectedProvince,
      );
    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }finally{
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context); // No uses listen: false aquí

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio Paciente'),
        actions: [
          IconButton(
            onPressed: () => authService.signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedSpecialty.isNotEmpty ? _selectedSpecialty : null,
              hint: const Text('Selecciona una especialidad'),
              items: _specialties.map((specialty) {
                return DropdownMenuItem(
                  value: specialty,
                  child: Text(specialty),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSpecialty = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedProvince.isNotEmpty ? _selectedProvince : null,
              hint: const Text('Selecciona una provincia'),
              items: _provinces.map((province) {
                return DropdownMenuItem(
                  value: province,
                  child: Text(province),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProvince = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            _isLoading ? const CircularProgressIndicator() : ElevatedButton(
                onPressed: () => _searchDoctors(firestoreService), // Pasa firestoreService
                child: const Text('Buscar Doctores')
            ),

            const SizedBox(height: 20),
            Expanded(
              child: _doctors.isEmpty
                  ? const Center(child: Text('No se encontraron doctores.'))
                  : ListView.builder(
                itemCount: _doctors.length,
                itemBuilder: (context, index) {
                  final doctor = _doctors[index];
                  return ListTile(
                      title: Text(doctor.name),
                      subtitle: Text('${doctor.specialty} - ${doctor.consultationPlace}'),
                      trailing: Text('\$${doctor.consultationPrice.toStringAsFixed(2)}'), // Muestra el precio
                      onTap: () {
                        //Aqui mostrar los detalles y permitir agendar citas.
                      }
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}