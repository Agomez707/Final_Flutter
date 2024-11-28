import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:authclase/services/store_services.dart';
import 'package:intl/intl.dart';

class AddVaccineScreen extends StatefulWidget {
  final String petId;

  const AddVaccineScreen({
  super.key, 
  required this.petId
  });

  @override
  _AddVaccineScreenState createState() => _AddVaccineScreenState();
}

class _AddVaccineScreenState extends State<AddVaccineScreen> {
  final FirebaseService _firebaseService = FirebaseService();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration:
                  const InputDecoration(
                    labelText: 'Nombre de la vacuna',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.vaccines_outlined),
                    ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dateController,
              decoration:
                  const InputDecoration(
                    labelText: 'Fecha de aplicación',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.date_range),
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
            const SizedBox(height: 10),
            TextField(
              controller: _nextDateController,
              decoration:
                  const InputDecoration(
                    labelText: 'Proxima aplicación',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.date_range),
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
                  

                  if (name.isEmpty || _selectedDate == null || _selectedNextDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Por favor, complete todos los campos')),
                    );
                    return;
                  }

                  try {
                    await _firebaseService.addVaccine(widget.petId, {
                      'name': name,
                      'date': Timestamp.fromDate(_selectedDate!),
                      'next_due_date': Timestamp.fromDate(_selectedNextDate!),
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Vacuna agregada correctamente')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error al agregar la vacuna')),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
