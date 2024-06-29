import 'package:flutter/material.dart';

class CustomAlertDialogShape extends RoundedRectangleBorder {
  @override
  final double radiuos;

  CustomAlertDialogShape({this.radiuos = 10.0})
      : super(
          borderRadius: BorderRadius.circular(radiuos),
        );

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radiuos)),
      );
  }
}
