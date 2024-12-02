import 'package:authclase/pages/add/add_person_page.dart';
import 'package:authclase/pages/edits/edit_person.dart';
import 'package:authclase/pages/person_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:authclase/services/store_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  final FirebaseService _firebaseService = FirebaseService();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Lista de Personas')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por ID...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Color.fromARGB(255, 114, 11, 114),
            ),
            onPressed: signUserOut,
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseService.getPersonsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final personsData = snapshot.data?.docs.where((doc) {
            if (searchQuery.isEmpty) return true;
            return doc.id.contains(searchQuery);
          }).toList();

          if (personsData == null || personsData.isEmpty) {
            return const Center(child: Text('No hay personas disponibles'));
          }

          return ListView.builder(
            itemCount: personsData.length,
            itemBuilder: (context, index) {
              final person = personsData[index];
              final personId = person.id;
              final personName = person['name'];

              return ListTile(
                title: Text(personName),
                subtitle: Text('ID: $personId'),
                leading: const Icon(Icons.person),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PersonDetailsScreen(personId: personId),
                    ),
                  );
                },
                trailing: PopupMenuButton(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      // Ir a la pantalla de edición
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditPersonScreen(personId: personId),
                        ),
                      );
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Center(
                              child: Text('Confirmar eliminación')),
                          content: const Text(
                              '¿Está seguro de que desea eliminar esta Persona y sus mascotas?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await FirebaseService().deletePersonAndPets(personId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Persona eliminada')),
                        );
                      }
                    }
                  },
                  //opciones de menu desplegable
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Editar'),
                    ),
                    PopupMenuItem(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPersonScreen(),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 226, 124, 240),
        child: const Icon(Icons.add),
      ),

    );
  }
}
