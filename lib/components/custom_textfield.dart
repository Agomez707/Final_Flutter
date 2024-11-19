import 'package:flutter/material.dart';

class Customtextfield extends StatelessWidget {
  final String miHintText;
  final bool obscureText;
  final controller;
  final IconData icon;

  const Customtextfield({
    super.key,
    required this.miHintText,
    required this.obscureText,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: miHintText,
          hintStyle: const TextStyle(color: Color.fromARGB(255, 184, 181, 181)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }
}
