import 'package:flutter/material.dart';
class TextWidget extends StatelessWidget {
  Color color;
  double size;
  String text;
  FontWeight fontWeight;
  double letterSpacing;
  TextWidget({required this.color,required this.size,required this.text,required this.fontWeight,required this.letterSpacing});

  @override
  Widget build(BuildContext context) {
    return  Text(
      textAlign: TextAlign.center,
          text,style: TextStyle(

      letterSpacing: letterSpacing,
      fontSize: size,
      fontWeight: fontWeight,
      color: color,
    ),
    );
  }
}
