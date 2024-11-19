import 'package:authclase/pages/pets_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:authclase/services/store_services.dart';

class PersonDetailsScreen extends StatelessWidget {
  final String personId;
  final FirebaseService firebaseService = FirebaseService();

  PersonDetailsScreen({
    super.key, 
    required this.personId
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Persona'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: firebaseService.getPersonByID(personId),
        builder: (context, snapshot) {
          final personData = snapshot.data?.data() as Map<String, dynamic>?;

          if (personData == null) {
            return const Center(child: Text('No se encontró la persona'));
          }

          final personName = personData['name'];
          final personPhone = personData['phone'];
          final personEmail = personData['email'];
          final personAddress = personData['address'];

          final List<DocumentReference> petReferences =
              List<DocumentReference>.from(personData['pets'] ?? []);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: $personName',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Teléfono: $personPhone',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Email: $personEmail',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Direccion: $personAddress',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                const Text('Mascotas:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: FutureBuilder<List<DocumentSnapshot>>(
                    future: firebaseService.getPetsDetails(petReferences),
                    builder: (context, petsSnapshot) {
                      final petsData = petsSnapshot.data ?? [];

                      return ListView.builder(
                        itemCount: petsData.length,
                        itemBuilder: (context, index) {
                          final petData =
                              petsData[index].data() as Map<String, dynamic>;
                          final petName = petData['name'] ?? 'Sin nombre';
                          final petBreed = petData['breed'] ?? 'Sin raza';

                          return ListTile(
                            title: Text(petName),
                            subtitle: Text('$petBreed'),
                            leading: petData.containsKey('photo_url') &&
                                    petData['photo_url'] != null
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(petData['photo_url']),
                                    radius: 24,
                                  )
                                : CircleAvatar(
                                    child: Icon(Icons.pets),
                                    radius: 24,
                                  ),
                            onTap: () {
                              // Navegar a la pantalla de detalles de la mascota
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PetDetailsScreen(
                                      petId: petsData[index].id),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
