import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class FirebaseService {
  //CollectionReference persons = FirebaseFirestore.instance.collection('persons');

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //Personas

  // Función para obtener la lista de personas
  Stream<QuerySnapshot> getPersonsStream() {
    return firestore
      .collection('persons')
      .snapshots();
  }

  // Función para obtener los datos de una persona específica por ID
  Future<DocumentSnapshot> getPerson(String personId) {
    return firestore
      .collection('persons')
      .doc(personId)
      .get();
  }

  // Función para obtener los datos de una persona específica por ID
  Stream<DocumentSnapshot> getPersonByID(String personId) {
    return firestore
      .collection('persons')
      .doc(personId)
      .snapshots();
  }

  // Función para obtener los datos de las mascotas de una persona
  Future<List<DocumentSnapshot>> getPetsDetails(
      List<DocumentReference> petReferences) async {
    final petsSnapshots =
        await Future.wait(petReferences.map((ref) => ref.get()).toList());
    return petsSnapshots;
  }

  // Editar una nueva Persona
  Future<void> updatePerson(
      String personId, Map<String, dynamic> updatedData) async {
    await firestore
      .collection('persons')
      .doc(personId)
      .update(updatedData);
  }

  // Agregar una nueva Persona
  Future<void> addPerson(String id, Map<String, dynamic> personData) async {
    await firestore
      .collection('persons')
      .doc(id)
      .set(personData);
  }

  Future<void> deletePersonAndPets(String personId) async {
    try {
      // Referencia a la persona
      DocumentReference personRef =
          firestore.collection('persons').doc(personId);

      // Obtén los datos de la persona
      DocumentSnapshot personSnapshot = await personRef.get();

      if (!personSnapshot.exists) {
        throw Exception("La persona con ID $personId no existe.");
      }

      // Obtén la lista de mascotas (puede ser lista de referencias o IDs)
      List<dynamic> pets = personSnapshot['pets'] ?? [];

      // Inicia una transacción para realizar las eliminaciones
      await firestore.runTransaction((transaction) async {
        // Elimina todas las mascotas relacionadas
        for (var pet in pets) {
          if (pet is String) {
            // Si es un ID de mascota
            transaction.delete(firestore.collection('pets').doc(pet));
          } else if (pet is DocumentReference) {
            // Si es una referencia a un documento
            transaction.delete(pet);
          }
        }

        // Elimina la persona
        transaction.delete(personRef);
      });

      print('Persona y sus mascotas eliminadas correctamente.');
    } catch (e) {
      print('Error al eliminar persona y mascotas: $e');
      rethrow; 
    }
  }

  //Mascotas

  // Función para obtener los detalles de una mascota específica
  Future<DocumentSnapshot> getPetDetails(String petId) {
    return firestore
      .collection('pets')
      .doc(petId)
      .get();
  }

  // Obtener mascotas de una persona en tiempo real
  Stream<DocumentSnapshot> getPersonStream(String personId) {
    return firestore
      .collection('persons')
      .doc(personId)
      .snapshots();
  }

  // Obtener los datos de una lista de referencias de mascotas
  Future<List<DocumentSnapshot>> getPetsData(
      List<DocumentReference> petRefs) async {
    return await Future.wait(petRefs.map((ref) => ref.get()));
  }

// Agregar una nueva mascota
  Future<String> addPet(Map<String, dynamic> petData) async {
    final petDoc = await firestore
      .collection('pets')
      .add(petData);

    return petDoc.id;
  }

// Actualizar el array de mascotas en una persona
  Future<void> addPetToPerson(String personId, DocumentReference petRef) async {
    await firestore
      .collection('persons')
      .doc(personId)
      .update({
        'pets': FieldValue.arrayUnion([petRef]),
    });
  }

// Editar detalles de una mascota
  Future<void> updatePet(String petId, Map<String, dynamic> updatedData) async {
    await firestore
      .collection('pets')
      .doc(petId)
      .update(updatedData);
  }

  // Eliminar una mascota (y su referencia en una persona)
  Future<void> deletePet(String personId, String petId) async {
    // Eliminar la referencia de la mascota en 'persons'
    final petRef = firestore.doc('pets/$petId');

    await firestore
      .collection('persons')
      .doc(personId)
      .update({
        'pets': FieldValue.arrayRemove([petRef]),
    });
    // Eliminar la mascota de la colección 'pets'
    await firestore
      .collection('pets')
      .doc(petId)
      .delete();
  }

  //Historial Medico

  // Función para obtener el stream de la subcolección de historial médico
  Stream<QuerySnapshot> getMedicalHistoryStream(String petId) {
    return firestore
        .collection('pets')
        .doc(petId)
        .collection('medical_history')
        .snapshots();
  }

  //Función para agregar Hitorial medicos
  Future<void> addMedicalRecord(String petId, Map<String, dynamic> data) async {
    await firestore
        .collection('pets')
        .doc(petId)
        .collection('medical_history')
        .add(data);
  }

  // Eliminar Historial Medico
  Future<void> deleteRecord(String petId, String recordId) async {
    await firestore
        .collection('pets')
        .doc(petId)
        .collection('medical_history')
        .doc(recordId)
        .delete();
  }

  // Actualizar Historial Medico
  Future<void> updateRecord(
      String petId, String recordId, Map<String, dynamic> data) async {
    await firestore
        .collection('pets')
        .doc(petId)
        .collection('medical_history')
        .doc(recordId)
        .update(data);
  }

  //Vacunas

  // Función para obtener el stream de la subcolección de vacunas
  Stream<QuerySnapshot> getVaccinesStream(String petId) {
    return firestore
        .collection('pets')
        .doc(petId)
        .collection('vaccinations')
        .snapshots();
  }

  //Función para agregar vacunas
  Future<void> addVaccine(String petId, Map<String, dynamic> data) async {
    await firestore
        .collection('pets')
        .doc(petId)
        .collection('vaccinations')
        .add(data);
  }

  // Eliminar vacuna
  Future<void> deleteVaccine(String petId, String vaccineId) async {
    await firestore
        .collection('pets')
        .doc(petId)
        .collection('vaccinations')
        .doc(vaccineId)
        .delete();
  }

  // Actualizar vacuna
  Future<void> updateVaccine(
      String petId, String vaccineId, Map<String, dynamic> data) async {
    await firestore
        .collection('pets')
        .doc(petId)
        .collection('vaccinations')
        .doc(vaccineId)
        .update(data);
  }
}
