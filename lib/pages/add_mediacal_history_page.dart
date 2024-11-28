import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:authclase/services/store_services.dart';
import 'package:intl/intl.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  final String petId;

  const AddMedicalRecordScreen({
    super.key, 
    required this.petId
    });

  @override
  AddMedicalRecordScreenState createState() => AddMedicalRecordScreenState();
}

class AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Historial Médico'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Razón de visita',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Diagnóstico',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _treatmentController,
                decoration: const InputDecoration(
                  labelText: 'Tratamiento',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de visita',
                  prefixIcon: Icon(Icons.date_range),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _dateController.text =
                          DateFormat('dd/MM/yyyy').format(pickedDate);
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final reason = _reasonController.text.trim();
                    final diagnosis = _diagnosisController.text.trim();
                    final treatment = _treatmentController.text.trim();
                    final notes = _notesController.text.trim();

                    if (reason.isEmpty ||
                        diagnosis.isEmpty ||
                        treatment.isEmpty ||
                        notes.isEmpty ||
                        _selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Por favor, complete todos los campos')),
                      );
                      return;
                    }

                    try {
                      await _firebaseService.addMedicalRecord(widget.petId, {
                        'reason': reason,
                        'diagnosis': diagnosis,
                        'treatment': treatment,
                        'notes': notes,
                        'date': Timestamp.fromDate(_selectedDate!),
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Historial médico agregado correctamente')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Error al agregar el historial médico')),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
