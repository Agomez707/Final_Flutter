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

    // Inicializa el controlador de la fecha
    _dateController = TextEditingController(
      text: widget.initialData['date'] != null
          ? DateFormat('dd/MM/yyyy')
              .format((widget.initialData['date'] as Timestamp).toDate())
          : '',
    );

    // Inicializa el controlador de la próxima fecha utilizando next_due_date
    _nextDateController = TextEditingController(
      text: widget.initialData['next_due_date'] != null
          ? DateFormat('dd/MM/yyyy').format(
              (widget.initialData['next_due_date'] as Timestamp).toDate())
          : '',
    );
    print('intialData: ${widget.initialData['next_due_date']}');

    // Convierte el Timestamp a DateTime para manipulación
    _selectedDate = widget.initialData['date'] != null
        ? (widget.initialData['date'] as Timestamp).toDate()
        : null;

    _selectedNextDate = widget.initialData['next_due_date'] != null
        ? (widget.initialData['next_due_date'] as Timestamp).toDate()
        : null;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la vacuna',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vaccines_outlined),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Seleccione una fecha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.date_range),
              ),
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
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nextDateController,
              decoration: const InputDecoration(
                labelText: 'Próxima fecha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.date_range),
              ),
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
                onPressed: () async {
                  final name = _nameController.text.trim();

                  if (name.isEmpty || _selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Por favor, complete todos los campos')),
                    );
                    return;
                  }

                  await FirebaseService().updateVaccine(
                    widget.petId,
                    widget.vaccineId,
                    {
                      'name': name,
                      'date': Timestamp.fromDate(_selectedDate!),
                      'next_due_date': _selectedNextDate != null
                          ? Timestamp.fromDate(_selectedNextDate!)
                          : null,
                    },
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vacuna actualizada correctamente')),
                  );
                },
                child: const Text('Guardar Cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}