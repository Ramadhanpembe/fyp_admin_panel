import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 32.0,
      height: 32.0,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.black,
          strokeWidth: 3.0,
        ),
      ),
    );
  }
}
