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
  final _formKey = GlobalKey<FormState>();
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

  _reasonController = TextEditingController(
    text: widget.initialData['reason'],
  );
  _diagnosisController = TextEditingController(
    text: widget.initialData['diagnosis'],
  );
  _treatmentController = TextEditingController(
    text: widget.initialData['treatment'],
  );
  _notesController = TextEditingController(
    text: widget.initialData['notes'],
  );

  // Manejo de la fecha
  var dateData = widget.initialData['date'];
  if (dateData is Timestamp) {
    _selectedDate = dateData.toDate(); // Si es Timestamp, conviértelo a DateTime
  } else if (dateData is String) {
    try {
      _selectedDate = DateFormat('dd/MM/yyyy').parse(dateData); // Si es String, parsea
    } catch (e) {
      _selectedDate = null; // Maneja errores de formato
    }
  }

  _dateController = TextEditingController(
    text: _selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
        : '',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _reasonController,
                  label: 'Razón de visita',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese la razón de la visita'
                      : null,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _diagnosisController,
                  label: 'Diagnóstico',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese el diagnóstico'
                      : null,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _treatmentController,
                  label: 'Tratamiento',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese el tratamiento'
                      : null,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _notesController,
                  label: 'Notas',
                  maxLines: 4,
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
                    child: const Text('Guardar Cambios'),
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
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.date_range),
        border: const OutlineInputBorder(),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
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
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    try {
      final reason = _reasonController.text.trim();
      final diagnosis = _diagnosisController.text.trim();
      final treatment = _treatmentController.text.trim();
      final notes = _notesController.text.trim();

      await _firebaseService.updateRecord(
        widget.petId,
        widget.recordId,
        {
          'reason': reason,
          'diagnosis': diagnosis,
          'treatment': treatment,
          'notes': notes,
          'date': Timestamp.fromDate(_selectedDate!),
        },
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historial médico editado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al editar el historial médico: $e')),
      );
    }
  }
}
