import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:authclase/services/store_services.dart';
import 'package:intl/intl.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  final String petId;

  const AddMedicalRecordScreen({
    super.key,
    required this.petId,
  });

  @override
  AddMedicalRecordScreenState createState() => AddMedicalRecordScreenState();
}

class AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

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
        title: const Text('Agregar Historial Médico'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _reasonController,
                  label: 'Razón de visita',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese la razón de la visita';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _diagnosisController,
                  label: 'Diagnóstico',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el diagnóstico';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _treatmentController,
                  label: 'Tratamiento',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el tratamiento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _notesController,
                  label: 'Notas',
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese las notas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildDatePickerField(
                  controller: _dateController,
                  label: 'Fecha de visita',
                  onDateSelected: (pickedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String label,
    required Function(DateTime pickedDate) onDateSelected,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.date_range),
        border: const OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
          controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
        }
      },
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos'),
        ),
      );
      return;
    }

    try {
      final reason = _reasonController.text.trim();
      final diagnosis = _diagnosisController.text.trim();
      final treatment = _treatmentController.text.trim();
      final notes = _notesController.text.trim();

      await _firebaseService.addMedicalRecord(widget.petId, {
        'reason': reason,
        'diagnosis': diagnosis,
        'treatment': treatment,
        'notes': notes,
        'date': Timestamp.fromDate(_selectedDate!),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historial médico agregado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar el historial médico: $e')),
      );
    }
  }
}
