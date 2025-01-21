import 'package:akilli_anahtar/utils/constants.dart';
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width(context) * 0.02),
        child: child,
      ),
    );
  }
}
