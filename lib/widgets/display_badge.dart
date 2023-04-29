import 'package:flutter/material.dart';

class DisplayBadge extends StatelessWidget {
  const DisplayBadge({
    super.key,
    this.color = Colors.white,
    required this.value,
    required this.title,
  });

  final Color color;
  final Widget value;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          value,
          Text(
            title,
            style: const TextStyle(letterSpacing: 2.0, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
