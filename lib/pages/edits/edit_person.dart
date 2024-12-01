import 'package:flutter/material.dart';
import 'package:authclase/services/store_services.dart';
import 'package:authclase/components/custom_widget.dart';

class EditPersonScreen extends StatefulWidget {
  final String personId;

  const EditPersonScreen({
    super.key,
    required this.personId
    });

  @override
  EditPersonScreenState createState() => EditPersonScreenState();
}

class EditPersonScreenState extends State<EditPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

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
      final personData = await FirebaseService().getPerson(widget.personId);

      if (personData.exists) {
        final data = personData.data() as Map<String, dynamic>;
        _nameController = TextEditingController(text: data['name'] ?? '');
        _addressController = TextEditingController(text: data['address'] ?? '');
        _emailController = TextEditingController(text: data['email'] ?? '');
        _phoneController =
            TextEditingController(text: (data['phone'] ?? '').toString());
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

  void _updatePerson() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseService().updatePerson(
        widget.personId,
        {
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': int.parse(_phoneController.text.trim()),
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Persona actualizada con éxito')),
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
        title: const Text('Editar datos de Persona'),
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
                validator: (value) =>
                    value == null || value.isEmpty 
                    ? 'Ingrese un nombre' 
                    : null,
              ),
              const SizedBox(height: 16),
              CustomWidgets.buildTextField(
                controller: _addressController,
                label: 'Dirección',
                validator: (value) =>
                    value == null || value.isEmpty 
                    ? 'Ingrese una dirección' 
                    : null,
              ),
              const SizedBox(height: 16),
              CustomWidgets.buildTextField(
                controller: _emailController,
                label: 'Email',
                validator: (value) =>
                    value == null || value.isEmpty 
                    ? 'Ingrese un email' 
                    : null,
              ),
              const SizedBox(height: 16),
              CustomWidgets.buildTextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                label: 'Telefono',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un telefono válida';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePerson,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}