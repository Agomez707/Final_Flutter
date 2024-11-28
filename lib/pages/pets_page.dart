import 'package:authclase/components/formatted_date.dart';
import 'package:authclase/pages/add_Vacuna_page.dart';
import 'package:authclase/pages/add_mediacal_history_page.dart';
import 'package:authclase/pages/edit_medical_history.dart';
import 'package:authclase/pages/edit_vacuna.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:authclase/services/store_services.dart';

class PetDetailsScreenDos extends StatefulWidget {
  final String petId;

  PetDetailsScreenDos({
    super.key, 
    required this.petId
    });

  @override
  State<PetDetailsScreenDos> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreenDos> {
  final FirebaseService _firebaseService = FirebaseService();
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalles de la Mascota'),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            tabs: const [
              Tab(text: 'Detalles', icon: Icon(Icons.info_outline)),
              Tab(text: 'Vacunas', icon: Icon(Icons.vaccines)),
              Tab(text: 'Historial', icon: Icon(Icons.history)),
              Tab(text: 'Turnos', icon: Icon(Icons.note_add)),
            ],
            labelColor: const Color.fromARGB(255, 119, 1, 134),
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña de Detalles
            FutureBuilder<DocumentSnapshot>(
              future: _firebaseService.getPetDetails(widget.petId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child:
                          Text('Error al cargar los detalles de la mascota'));
                }

                final petData = snapshot.data?.data() as Map<String, dynamic>?;
                if (petData == null) {
                  return const Center(
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
                      const SizedBox(height: 16),
                      Text('Nombre: $petName',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Especie: $petSpecies',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Raza: $petBreed',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Edad: $petAge',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Sexo: $petSex',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Color: $petColor',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              },
            ),

            // Pestaña de Vacunas
            StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getVaccinesStream(widget.petId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error al cargar las vacunas'));
                }

                final vaccinesData = snapshot.data?.docs;
                if (vaccinesData == null || vaccinesData.isEmpty) {
                  return const Center(
                      child: Text('No hay vacunas registradas'));
                }

                return ListView.builder(
                  itemCount: vaccinesData.length,
                  itemBuilder: (context, index) {
                    final vaccine = vaccinesData[index];
                    final vaccineId = vaccine.id;
                    final vaccineName = vaccine['name'] ?? 'Sin nombre';
                    final vaccineDate = formatDate(vaccine['date']);
                    final vaccineNextDate =
                        formatDate(vaccine['next_due_date']);

                    return ListTile(
                      title: Text(vaccineName),
                      subtitle: Text(
                          'Aplicada el: $vaccineDate\nSiguiente Dosis: $vaccineNextDate'),
                      leading: const Icon(Icons.vaccines),
                      //menu desplegable para opciones Editar y Eliminar
                      trailing: PopupMenuButton(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            // Ir a la pantalla de edición
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditVaccineScreen(
                                  petId: widget.petId,
                                  vaccineId: vaccineId,
                                  initialData: {
                                    'name': vaccineName,
                                    'date': vaccine['date'],
                                    'next_due_date': vaccine['next_due_date'],
                                  },
                                ),
                              ),
                            );
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Center( child: Text('Confirmar eliminación')),
                                content: const Text(
                                    '¿Está seguro de que desea eliminar esta vacuna?'),
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
                              await FirebaseService()
                                  .deleteVaccine(widget.petId, vaccineId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Vacuna eliminada')),
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

            // Pestaña de Historial Médico
            StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getMedicalHistoryStream(widget.petId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error al cargar el historial médico'));
                }

                final historyData = snapshot.data?.docs;
                if (historyData == null || historyData.isEmpty) {
                  return const Center(
                      child: Text('No hay historial médico registrado'));
                }

                return ListView.builder(
                  itemCount: historyData.length,
                  itemBuilder: (context, index) {
                    final record = historyData[index];
                    final recordId = record.id;
                    final reason = record['reason'] ?? 'Sin diagnóstico';
                    final diagnosis = record['diagnosis'] ?? 'Sin diagnóstico';
                    final treatment = record['treatment'] ?? 'Sin tratamiento';
                    final notes = record['notes'] ?? 'Sin diagnóstico';
                    final date = formatDate(record['date']);

                    return ListTile(
                      title: Text(reason),
                      subtitle: Text(
                          'Diagnostico: $diagnosis\nTratamiento: $treatment\nFecha: $date\nNota: $notes'),
                      leading: const Icon(Icons.history),
                      trailing: PopupMenuButton(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            // Ir a la pantalla de edición
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditMedicalRecordScreen(
                                  petId: widget.petId,
                                  recordId: recordId,
                                  initialData: {
                                    'reason': reason,
                                    'diagnosis': diagnosis,
                                    'treatment': treatment,
                                    'notes': notes,
                                    'date': date,
                                  },                                  
                                ),
                              ),
                            );


                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Center( child: Text('Confirmar eliminación')),
                                content: const Text(
                                    '¿Está seguro de que desea eliminar este Historial?'),
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
                              await FirebaseService()
                                  .deleteRecord(widget.petId, recordId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Historial eliminada')),
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
            Scaffold(),
          ],
        ),
        floatingActionButton: _currentTabIndex == 1 ||
                _currentTabIndex == 2 ||
                _currentTabIndex == 3
            ? FloatingActionButton(
                onPressed: () {
                  if (_currentTabIndex == 1) {
                    // Acción para añadir una vacuna
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddVaccineScreen(petId: widget.petId),
                      ),
                    );
                  } else if (_currentTabIndex == 2) {
                    // Acción para añadir un registro médico
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddMedicalRecordScreen(petId: widget.petId),
                      ),
                    );
                  }
                },
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
