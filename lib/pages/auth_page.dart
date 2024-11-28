import 'package:authclase/pages/home.dart';
import 'package:authclase/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class AuthPage extends StatelessWidget {
const AuthPage({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(), 
          builder: (context, snapshot){
            if(snapshot.hasData){
              return MyHomePage();
            }else{
              return LoginPage();
            }
          }
          ),
      )
    );
  }
}

