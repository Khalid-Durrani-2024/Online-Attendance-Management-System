import 'package:flutter/material.dart';

class TextFields extends StatelessWidget {
  TextFields(
      {required this.hint,
      required this.text,
      this.obsecure = false,
      ControllerText});
  String hint;
  Text text;
  bool obsecure;
  var ControllerText;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: ControllerText,
        obscureText: obsecure,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.2,
        ),
        decoration: InputDecoration(
          hintText: hint,
          label: text,
        ),
      ),
    );
  }
}
