import 'package:flutter/material.dart';
import 'package:authclase/services/store_services.dart';
import 'package:authclase/components/custom_widget.dart';


class EditPetScreen extends StatefulWidget {
  final String petId;

  const EditPetScreen({
    super.key,
    required this.petId
    });

  @override
  EditPetScreenState createState() => EditPetScreenState();
}

class EditPetScreenState extends State<EditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _colorController;
  late TextEditingController _speciesController;
  late TextEditingController _birthYearController;
  late TextEditingController _sexController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializePetData();
  }

  void _initializePetData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final petData = await FirebaseService().getPetDetails(widget.petId);

      if (petData.exists) {
        final data = petData.data() as Map<String, dynamic>;
        _nameController = TextEditingController(text: data['name'] ?? '');
        _breedController = TextEditingController(text: data['breed'] ?? '');
        _colorController = TextEditingController(text: data['color'] ?? '');
        _speciesController = TextEditingController(text: data['species'] ?? '');
        _sexController = TextEditingController(text: data['sex'] ?? '');
        _birthYearController =
            TextEditingController(text: (data['birth_age'] ?? '').toString());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updatePet() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseService().updatePet(
        widget.petId,
        {
          'name': _nameController.text.trim(),
          'breed': _breedController.text.trim(),
          'color': _colorController.text.trim(),
          'species': _speciesController.text.trim(),
          'sex': _sexController.text.trim(),
          'birth_age': int.parse(_birthYearController.text.trim()),
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mascota actualizada con éxito')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Mascota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomWidgets.buildTextField(
                controller: _nameController,
                label: 'Nombre',
                icon: Icons.pets,
                validator: (value) =>
                    value == null || value.isEmpty 
                    ? 'Ingrese un nombre' 
                    : null,
              ),
              const SizedBox(height: 16),
              CustomWidgets.buildTextField(
                controller: _breedController,
                label: 'Raza',
                icon: Icons.pets,
                validator: (value) =>
                    value == null || value.isEmpty 
                    ? 'Ingrese la Raza' 
                    : null,
              ),
              const SizedBox(height: 16),
              CustomWidgets.buildTextField(
                controller: _colorController,
                label: 'Color',
                icon: Icons.pets,
                validator: (value) =>
                    value == null || value.isEmpty 
                    ? 'Ingrese el color' 
                    : null,
              ),
              const SizedBox(height: 16),
              CustomWidgets.buildTextField(
                controller: _speciesController,
                label: 'Especie',
                icon: Icons.pets,
                validator: (value) =>
                    value == null || value.isEmpty 
                    ? 'Ingrese la especie' 
                    : null,
              ),
              const SizedBox(height: 16),
              CustomWidgets.buildTextField(
                controller: _sexController,
                label: 'Sexo',
                icon: Icons.pets,
                validator: (value) =>
                    value == null || value.isEmpty 
                    ? 'Ingrese el sexo' 
                    : null,
              ),
              const SizedBox(height: 16),
              CustomWidgets.buildTextField(
                controller: _birthYearController,
                keyboardType: TextInputType.number,
                label: 'Año de Nacimiento',
                icon: Icons.date_range,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el año de nacimiento';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePet,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 226, 124, 240),
                    foregroundColor: Colors.black,
                    
                  ),
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}