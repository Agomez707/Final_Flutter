import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {

    final String textButton;
    final Function() ontap;

    const CustomButton({
        super.key,
        required this.textButton,
        required this.ontap,
    });

    @override
    Widget build(BuildContext context) {
    return GestureDetector(
        onTap: ontap,
        child: Container(
        //padding: const EdgeInsets.all(25),
        //margin: const EdgeInsets.symmetric(horizontal: 25),
        width: 200,
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.blueAccent,
            ),
        child: Center(
            child: Text(
            textButton,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
            ),
            ),
        ),
        ),
    );
    }
}
