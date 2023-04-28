import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key, required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96.0,
      width: double.infinity,
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: Colors.black12,
        width: 1.0,
      ))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 22.0),
        child: CircleAvatar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          child: Text(
            'PMS',
            style: TextStyle(fontSize: fontSize),
          ),
        ),
      ),
    );
  }
}
