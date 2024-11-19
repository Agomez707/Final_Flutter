import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:authclase/services/store_services.dart';


class MedicalHistoryScreen extends StatelessWidget {
  final String petId;
  final FirebaseService _firebaseService = FirebaseService();

  MedicalHistoryScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial Médico'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseService.getMedicalHistoryStream(petId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar el historial médico'));
          }

          final historyData = snapshot.data?.docs;
          if (historyData == null || historyData.isEmpty) {
            return Center(child: Text('No hay historial médico registrado'));
          }

          return ListView.builder(
            itemCount: historyData.length,
            itemBuilder: (context, index) {
              final record = historyData[index];
              final reason = record['reason'] ?? 'Sin diagnóstico';
              final diagnosis = record['diagnosis'] ?? 'Sin diagnóstico';
              final treatment = record['treatment'] ?? 'Sin tratamiento';
              final notes = record['notes'] ?? 'Sin diagnóstico';
              final date = record['date'] ?? 'Fecha desconocida';

              return ListTile(
                title: Text(reason),
                subtitle: Text('Diagnostico: $diagnosis\nTratamiento: $treatment\nFecha: $date\nNota: $notes'),
              );
            },
          );
        },
      ),
    );
  }
}