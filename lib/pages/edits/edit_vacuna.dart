import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:authclase/services/store_services.dart';
import 'package:intl/intl.dart';

class EditVaccineScreen extends StatefulWidget {
  final String petId;
  final String vaccineId;
  final Map<String, dynamic> initialData;

  const EditVaccineScreen({
    super.key,
    required this.petId,
    required this.vaccineId,
    required this.initialData,
  });

  @override
  EditVaccineScreenState createState() => EditVaccineScreenState();
}

class EditVaccineScreenState extends State<EditVaccineScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _nextDateController;

  DateTime? _selectedDate;
  DateTime? _selectedNextDate;

  @override
  void initState() {
    super.initState();

    // Inicializa el controlador del nombre de la vacuna
    _nameController = TextEditingController(
      text: widget.initialData['name'] ?? '',
    );

    // Manejo de la fecha actual
    var dateData = widget.initialData['date'];
    if (dateData is Timestamp) {
      _selectedDate = dateData.toDate();
    } else if (dateData is String) {
      try {
        _selectedDate = DateFormat('dd/MM/yyyy').parse(dateData);
      } catch (e) {
        _selectedDate = null;
      }
    }
    _dateController = TextEditingController(
      text: _selectedDate != null
          ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
          : '',
    );

    // Manejo de la próxima fecha
    var nextDateData = widget.initialData['next_due_date'];
    if (nextDateData is Timestamp) {
      _selectedNextDate = nextDateData.toDate();
    } else if (nextDateData is String) {
      try {
        _selectedNextDate = DateFormat('dd/MM/yyyy').parse(nextDateData);
      } catch (e) {
        _selectedNextDate = null;
      }
    }
    _nextDateController = TextEditingController(
      text: _selectedNextDate != null
          ? DateFormat('dd/MM/yyyy').format(_selectedNextDate!)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _nextDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Vacuna'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la vacuna',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vaccines_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre de la vacuna';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Seleccione una fecha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, seleccione una fecha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nextDateController,
                decoration: const InputDecoration(
                  labelText: 'Próxima fecha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedNextDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedNextDate = pickedDate;
                      _nextDateController.text =
                          DateFormat('dd/MM/yyyy').format(pickedDate);
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _editVaccine,
                  child: const Text('Guardar Cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editVaccine() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseService().updateVaccine(
          widget.petId,
          widget.vaccineId,
          {
            'name': _nameController.text.trim(),
            'date': Timestamp.fromDate(_selectedDate!),
            'next_due_date': _selectedNextDate != null
                ? Timestamp.fromDate(_selectedNextDate!)
                : null,
          },
        );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vacuna actualizada correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al actualizar la vacuna: ${e.toString()}')),
        );
      }
    }
  }
}
