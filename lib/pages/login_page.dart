import 'package:authclase/components/button_login.dart';
import 'package:authclase/components/custom_button.dart';
import 'package:authclase/components/custom_textfield.dart';
import 'package:authclase/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userNameCOntroller = TextEditingController();
  final passwordCOntroller = TextEditingController();

  Future singUser() async {
    BuildContext dialogContex = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContex = context;
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userNameCOntroller.text,
        password: passwordCOntroller.text,
      );
      if (mounted) {
        Navigator.of(dialogContex).pop();
      } else {
        print('estamos teniendo problemas con el context');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(dialogContex).pop();
      } else {
        print('estamos teniendo problemas con el context');
      }

      if (e.code == 'user_not_found') {
        print(e.code);
      } else if (e.code == 'wrong_password') {
        print(e.code);
      } else if (e.code == 'invalid_email') {
        print(e.code);
      } else
        () {
          print('error desconocido $e.code');
        };
    } catch (e) {
      print('error inesperado');
    }
  }

  void signInUserGoogle() {
    AuthServices().signInGoogle();
    print('iniciando con google');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 235, 235, 235),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Título
                  const Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    'Inicia sesión para continuar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //Icono de persona
                  const Icon(
                    Icons.person,
                    size: 100,
                  ),
                  //Campos de Mail y contraseña
                  Customtextfield(
                    miHintText: 'Introduzca su Mail',
                    obscureText: false,
                    controller: userNameCOntroller,
                    icon: Icons.email,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Customtextfield(
                    miHintText: 'Introduzca su Constraseña',
                    obscureText: true,
                    controller: passwordCOntroller,
                    icon: Icons.lock,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //Boton de Ingresar
                  CustomButton(
                    textButton: 'Ingresar',
                    ontap: () {
                      // Validación de campos
                      if (userNameCOntroller.text.isEmpty ||
                          passwordCOntroller.text.isEmpty) {
                        // Muestra un mensaje de advertencia si algún campo está vacío
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Por favor, completa todos los campos'),
                            backgroundColor: Color.fromARGB(255, 255, 167, 3),
                          ),
                        );
                      } else {
                        singUser();
                      }
                    },
                  ),
                  // Opción para registro o recuperación de contraseña
                  TextButton(
                    onPressed: () {
                      // Acción para recuperar contraseña o registrarse
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  //linea divisora
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                            child: Divider(
                          thickness: 0.8,
                          color: Color.fromARGB(255, 184, 181, 181),
                        )),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            'O ingresa con: ',
                            style: TextStyle(
                                color: Color.fromARGB(255, 184, 181, 181)),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.8,
                            color: Color.fromARGB(255, 184, 181, 181),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ButtonLogin(
                      imagePath: 'lib/images/google.png',
                      ontap: signInUserGoogle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
