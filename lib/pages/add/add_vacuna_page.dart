import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:authclase/services/store_services.dart';
import 'package:authclase/components/custom_widget.dart';
import 'package:intl/intl.dart';

class AddVaccineScreen extends StatefulWidget {
  final String petId;

  const AddVaccineScreen({
    super.key,
    required this.petId,
  });

  @override
  AddVaccineScreenState createState() => AddVaccineScreenState();
}

class AddVaccineScreenState extends State<AddVaccineScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nextDateController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedNextDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Vacuna'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidgets.buildTextField(
                controller: _nameController,
                label: 'Nombre de la vacuna',
                icon: Icons.vaccines_outlined,
                validator: (value) =>
                    value == null || value.isEmpty 
                    ? 'Ingrese el nombre de la vacuna' 
                    : null,
              ),
              const SizedBox(height: 10),
              CustomWidgets.buildDateField(
                context: context,
                controller: _dateController,
                label: 'Fecha de aplicación',
                icon: Icons.date_range,
                onDateSelected: (pickedDate) {
                  _selectedDate = pickedDate;
                  _dateController.text =
                      DateFormat('dd/MM/yyyy').format(pickedDate);
                },
                validator: (value) =>
                    value == null || value.isEmpty 
                    ? 'Ingrese la fecha de aplicación' 
                    : null,
              ),
              const SizedBox(height: 10),
              CustomWidgets.buildDateField(
                context: context,
                controller: _nextDateController,
                label: 'Próxima aplicación',
                icon: Icons.date_range,
                onDateSelected: (pickedDate) {
                  _selectedNextDate = pickedDate;
                  _nextDateController.text =
                      DateFormat('dd/MM/yyyy').format(pickedDate);
                },
                validator: (value) =>
                    value == null || value.isEmpty 
                    ? 'Ingrese la fecha de la proxima aplicación' 
                    : null,
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
    );
  }


  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedNextDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione las fechas requeridas')),
      );
      return;
    }

    try {
      await _firebaseService.addVaccine(widget.petId, {
        'name': _nameController.text.trim(),
        'date': Timestamp.fromDate(_selectedDate!),
        'next_due_date': Timestamp.fromDate(_selectedNextDate!),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vacuna agregada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al agregar la vacuna')),
      );
    }
  }
}
