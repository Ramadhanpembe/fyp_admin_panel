import 'package:flutter/material.dart';

import 'header.dart';

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
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Center(
                  child: Header(),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
