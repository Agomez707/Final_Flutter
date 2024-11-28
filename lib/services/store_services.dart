import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class FirebaseService {
  //CollectionReference persons = FirebaseFirestore.instance.collection('persons');

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

   // Función para obtener la lista de personas
  Stream<QuerySnapshot> getPersonsStream() {
    return firestore.collection('persons').snapshots();
  }

  // Función para obtener los datos de una persona específica por ID
  Future<DocumentSnapshot> getPersonByID(String personId) {
    return firestore.collection('persons').doc(personId).get();
  }

  // Función para obtener los datos de las mascotas de una persona
  Future<List<DocumentSnapshot>> getPetsDetails(List<DocumentReference> petReferences) async {
    final petsSnapshots = await Future.wait(petReferences.map((ref) => ref.get()).toList());
    return petsSnapshots;
  }

  // Función para obtener los detalles de una mascota específica
  Future<DocumentSnapshot> getPetDetails(String petId) {
    return firestore.collection('pets').doc(petId).get();
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
    await firestore.collection('pets').doc(petId).collection('medical_history').add(data);
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
    await firestore.collection('pets').doc(petId).collection('vaccinations').add(data);
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