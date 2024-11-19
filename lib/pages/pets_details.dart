import 'package:authclase/pages/medical_history.dart';
import 'package:authclase/pages/vacunas_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:authclase/services/store_services.dart';

class PetDetailsScreen extends StatelessWidget {
  final String petId;
  final FirebaseService _firebaseService = FirebaseService();

  PetDetailsScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Mascota'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firebaseService.getPetDetails(petId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('Error al cargar los detalles de la mascota'));
          }

          final petData = snapshot.data?.data() as Map<String, dynamic>?;
          if (petData == null) {
            return const Center(
                child: Text('No se encontró la información de la mascota'));
          }

          final petName = petData['name'] ?? 'Sin nombre';
          final petBreed = petData['breed'] ?? 'Sin raza';
          final timeNow = DateTime.now();
          final petAge = timeNow.year - petData['birth_age'];
          final petImageUrl = petData['photo_url'];
          final petColor = petData['color'] ?? '';
          final petSex = petData['sex'] ?? '';
          final petSpecies = petData['species'] ?? '';

          return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: petImageUrl != null
                        ? Image.network(petImageUrl,
                            height: 200, fit: BoxFit.cover)
                        : const Icon(Icons.pets, size: 100),
                  ),
                  SizedBox(height: 16),
                  Text('Nombre: $petName',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Especie: $petSpecies', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Raza: $petBreed', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Edad: $petAge', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Sexo: $petSex', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Color: $petColor', style: TextStyle(fontSize: 16)),
                  Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VaccinesScreen(petId: petId),
                              ),
                            );
                          },
                          child: Text('Ver Vacunas'),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MedicalHistoryScreen(petId: petId),
                              ),
                            );
                          },
                          child: Text('Ver Historial Médico'),
                        ),
                      ],
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }
}
