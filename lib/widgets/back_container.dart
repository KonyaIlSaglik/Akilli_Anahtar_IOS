import 'package:flutter/material.dart';

class BackContainer extends StatelessWidget {
  final Widget? child;
  const BackContainer({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 1,
          colors: [
            Colors.brown[50]!,
            Colors.brown[50]!,
          ],
        ),
      ),
      child: child,
    );
  }
}
