import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:authclase/services/store_services.dart';

class PetDetailsScreenDos extends StatelessWidget {
  final String petId;
  final FirebaseService _firebaseService = FirebaseService();

  PetDetailsScreenDos({Key? key, required this.petId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: Text('Detalles de la Mascota'),
          bottom: TabBar(
            indicatorColor: const Color.fromARGB(255, 30, 1, 97), // Color de la línea indicadora
            labelColor: const Color.fromARGB(255, 0, 0, 0), // Color del texto seleccionado
            unselectedLabelColor: Colors.grey, // Color del texto no seleccionado
            tabs: [
              Tab(text: 'Detalles', icon: Icon(Icons.info_outline)),
              Tab(text: 'Vacunas', icon: Icon(Icons.vaccines)),
              Tab(text: 'Historial Médico', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña de Detalles
            FutureBuilder<DocumentSnapshot>(
              future: _firebaseService.getPetDetails(petId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child:
                          Text('Error al cargar los detalles de la mascota'));
                }

                final petData = snapshot.data?.data() as Map<String, dynamic>?;
                if (petData == null) {
                  return Center(
                      child:
                          Text('No se encontró la información de la mascota'));
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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Especie: $petSpecies',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Raza: $petBreed', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Edad: $petAge', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Sexo: $petSex', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Color: $petColor', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              },
            ),

            // Pestaña de Vacunas
            StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getVaccinesStream(petId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar las vacunas'));
                }

                final vaccinesData = snapshot.data?.docs;
                if (vaccinesData == null || vaccinesData.isEmpty) {
                  return Center(child: Text('No hay vacunas registradas'));
                }

                return ListView.builder(
                  itemCount: vaccinesData.length,
                  itemBuilder: (context, index) {
                    final vaccine = vaccinesData[index];
                    final vaccineName = vaccine['name'] ?? 'Sin nombre';
                    final vaccineDate = vaccine['date'] ?? 'Fecha desconocida';

                    return ListTile(
                      title: Text(vaccineName),
                      subtitle: Text('Fecha: $vaccineDate'),
                      leading: Icon(Icons.vaccines),
                    );
                  },
                );
              },
            ),

            // Pestaña de Historial Médico
            StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getMedicalHistoryStream(petId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error al cargar el historial médico'));
                }

                final historyData = snapshot.data?.docs;
                if (historyData == null || historyData.isEmpty) {
                  return Center(
                      child: Text('No hay historial médico registrado'));
                }

                return ListView.builder(
                  itemCount: historyData.length,
                  itemBuilder: (context, index) {
                    final record = historyData[index];
                    final diagnosis = record['diagnosis'] ?? 'Sin diagnóstico';
                    final treatment = record['treatment'] ?? 'Sin tratamiento';
                    final date = record['date'] ?? 'Fecha desconocida';

                    return ListTile(
                      title: Text(diagnosis),
                      subtitle: Text('Tratamiento: $treatment\nFecha: $date'),
                      leading: Icon(Icons.history),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
