import 'package:flutter/material.dart';

class SnackBarWidget extends StatefulWidget {
  String text;
  SnackBarWidget({required this.text});

  @override
  State<SnackBarWidget> createState() => _SnackBarWidgetState();
}

class _SnackBarWidgetState extends State<SnackBarWidget> {
  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(widget.text),
      duration: Duration(seconds: 4),
    );
  }
}
