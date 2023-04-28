import 'package:flutter/material.dart';

class Holder extends StatelessWidget {
  const Holder({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      margin: const EdgeInsets.fromLTRB(6.0, 12.0, 24.0, 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Center(
        child: child,
      ),
    );
  }
}
