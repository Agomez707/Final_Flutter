import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:authclase/services/store_services.dart';

class VaccinesScreen extends StatelessWidget {
  final String petId;
  final FirebaseService _firebaseService = FirebaseService();

  VaccinesScreen({Key? key, required this.petId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vacunas'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              //final vacuna = vaccineDate['paidDate']['_seconds'].toDate();

              return ListTile(
                title: Text(vaccineName),
                subtitle: Text('Fecha: $vaccineDate'),
              );
            },
          );
        },
      ),
    );
  }
}