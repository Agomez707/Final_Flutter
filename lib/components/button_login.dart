import 'package:flutter/material.dart';

class ButtonLogin extends StatelessWidget {

final String imagePath;
final Function()? ontap;

const ButtonLogin({
  super.key,
  required this.imagePath,
  required this.ontap,
  });

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: ontap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.black,
        ),
        child: Image.asset(
          imagePath,
          height: 40,
          ),
      ),
    );
  }
}
