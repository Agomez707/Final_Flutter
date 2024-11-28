import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:authclase/services/store_services.dart';
import 'package:intl/intl.dart';

class EditMedicalRecordScreen extends StatefulWidget {
  final String petId;
  final String recordId;
  final Map<String, dynamic> initialData;

  const EditMedicalRecordScreen({
    super.key, 
    required this.petId,
    required this.recordId,
    required this.initialData,
    });

  @override
  EditMedicalRecordScreenState createState() => EditMedicalRecordScreenState();
}

class EditMedicalRecordScreenState extends State<EditMedicalRecordScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  late TextEditingController _reasonController;
  late TextEditingController _diagnosisController;
  late TextEditingController _treatmentController;
  late TextEditingController _notesController;
  late TextEditingController _dateController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();


    // Inicializa el controlador de la Razon de visita
    _reasonController = TextEditingController(
      text: widget.initialData['reason'],
    );

    // Inicializa el controlador del diagnostico
    _diagnosisController = TextEditingController(
      text: widget.initialData['diagnosis'],
    );
    // Inicializa el controlador del tratamiento
    _treatmentController = TextEditingController(
      text: widget.initialData['treatment'],
    );

    // Inicializa el controlador del tratamiento
    _notesController = TextEditingController(
      text: widget.initialData['notes'],
    );

    // Inicializa el controlador de la fecha
    _dateController = TextEditingController(
      text: widget.initialData['date']
    );

  }

    @override
  void dispose() {
    _reasonController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Historial Médico'),
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
                      await _firebaseService.updateRecord(
                      widget.petId,
                      widget.recordId,
                      {
                        'reason': reason,
                        'diagnosis': diagnosis,
                        'treatment': treatment,
                        'notes': notes,
                        'date': Timestamp.fromDate(_selectedDate!),
                      }
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Historial médico editado correctamente')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Error al editar el historial médico')),
                      );
                    }
                  },
                  child: const Text('Guardar Cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
