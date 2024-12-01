import 'package:flutter/material.dart';
import 'package:authclase/services/store_services.dart';
import 'package:authclase/components/custom_widget.dart';

class AddPersonScreen extends StatefulWidget {
  const AddPersonScreen({
    super.key,
    });

  @override
  AddPersonScreenState createState() => AddPersonScreenState();
}

class AddPersonScreenState extends State<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  void _addPerson() async {
    if (_formKey.currentState?.validate() != true) return;

    final id = _idController.text.trim();
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = int.tryParse(_phoneController.text.trim());
    final email = _emailController.text.trim();

    if (id.isEmpty || name.isEmpty || phone == null || address.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseService().addPerson(id, {
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'pets': [], // Inicialmente sin mascotas
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Persona agregada con éxito')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar la persona: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Persona'),
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
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese un nombre válido'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomWidgets.buildTextField(
                controller: _idController,
                label: 'DNI',
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese un DNI válido'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomWidgets.buildTextField(
                controller: _addressController,
                label: 'Dirección',
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese una dirección válido'
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
                    return 'Debe ser un número';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomWidgets.buildTextField(
                controller: _emailController,
                label: 'Email',
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese una email válido'
                    : null,
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _addPerson,
                  child: const Text('Guardar Persona'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
