import 'package:flutter/material.dart';

import 'TextWidget.dart';

class ButtonWidget extends StatelessWidget {
  Color color;
  double size;
  String text;
  FontWeight fontWeight;
  double letterSpacing;
  double width;
  double height;
  double radius;
  Color bgColor;
  Color brColor;
  ButtonWidget({
    this.color = Colors.white,
    this.size = 30,
    required this.text,
    this.fontWeight = FontWeight.bold,
    this.letterSpacing = 0.4,
    this.height = 80,
    this.width = 250,
    this.radius = 15,
    this.bgColor = Colors.indigo,
    this.brColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Center(
        child: TextWidget(
          color: color,
          size: size,
          text: text,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
        ),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(width: 3, color: brColor),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
