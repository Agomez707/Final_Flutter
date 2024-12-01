//import 'package:authclase/pages/pets_details.dart';
import 'package:authclase/pages/add/add_pet_page.dart';
import 'package:authclase/pages/pets_page.dart';
import 'package:authclase/pages/edits/edit_pet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:authclase/services/store_services.dart';

class PersonDetailsScreen extends StatelessWidget {
  final String personId;
  final FirebaseService firebaseService = FirebaseService();

  PersonDetailsScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Persona'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firebaseService.getPersonByID(personId),
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
                          final petIdActual = petsData[index].id;

                          return ListTile(
                            title: Text(petName),
                            subtitle: Text('$petBreed'),
                            leading: petData['photo_url'] != null
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(petData['photo_url']),
                                    radius: 24,
                                  )
                                : const CircleAvatar(
                                    child: Icon(Icons.pets),
                                    radius: 24,
                                  ),
                            onTap: () {
                              // Navegar a la pantalla de detalles de la mascota
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PetDetailsScreenDos(
                                      petId: petIdActual),
                                ),
                              );
                            },
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  // Navegar a la pantalla de edición
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditPetScreen(petId: petIdActual),
                                    ),
                                  );
                                } else if (value == 'delete') {
                                  // Confirmar eliminación
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Center( child: Text('Eliminar Mascota')),
                                      content: const Text(
                                          '¿Estás seguro de que deseas eliminar esta mascota?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await FirebaseService()
                                          .deletePet(personId, petIdActual);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Mascota eliminada correctamente')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Error al eliminar la mascota: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Editar'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Eliminar'),
                                ),
                              ],
                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPetScreen(personId: personId),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 226, 124, 240),
        child: const Icon(Icons.pets),
      ),
    );
  }
}
