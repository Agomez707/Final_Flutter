import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:authclase/services/store_services.dart';
import 'package:authclase/components/custom_widget.dart';

class AddPetScreen extends StatefulWidget {
  final String personId;

  const AddPetScreen({
    super.key,
    required this.personId,
  });

  @override
  AddPetScreenState createState() => AddPetScreenState();
}

class AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _sexController = TextEditingController();
  final _speciesController = TextEditingController();
  final _birthYearController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _sexController.dispose();
    _speciesController.dispose();
    _birthYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Mascota')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomWidgets.buildTextField(
                  controller: _nameController,
                  label: 'Nombre de la Mascota',
                  icon: Icons.pets,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el nombre de la mascota';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  controller: _breedController,
                  label: 'Raza',
                  icon: Icons.pets,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese la raza';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  controller: _colorController,
                  label: 'Color',
                  icon: Icons.pets,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el color';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  controller: _sexController,
                  label: 'Sexo',
                  icon: Icons.pets,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el sexo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  controller: _speciesController,
                  label: 'Especie',
                  icon: Icons.pets,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese la especie';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  controller: _birthYearController,
                  label: 'Año de nacimiento',
                  icon: Icons.pets,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el año de nacimiento';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Ingrese un año válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Guardar Mascota'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final name = _nameController.text.trim();
      final breed = _breedController.text.trim();
      final color = _colorController.text.trim();
      final sex = _sexController.text.trim();
      final species = _speciesController.text.trim();
      final birthYear = int.parse(_birthYearController.text.trim());

      // Crear un nuevo documento en la colección 'pets'
      final petId = await FirebaseService().addPet({
        'name': name,
        'breed': breed,
        'color': color,
        'sex': sex,
        'species': species,
        'birth_age': birthYear,
      });

      // Crear una referencia al nuevo documento de 'pets'
      final petReference = FirebaseFirestore.instance.doc('pets/$petId');

      // Asociar la mascota a la persona
      await FirebaseService().addPetToPerson(widget.personId, petReference);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mascota agregada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar la mascota: $e')),
      );
    }
  }
}
