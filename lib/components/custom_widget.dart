import 'package:flutter/material.dart';


class CustomWidgets {
  // Widget para TextFormField genérico
  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  // Widget para TextFormField con selector de fecha
  static Widget buildDateField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    IconData? icon,
    required Function(DateTime) onDateSelected,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      readOnly: true,
      validator: validator,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
    );
  }


}
