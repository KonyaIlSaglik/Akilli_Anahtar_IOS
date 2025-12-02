import 'package:flutter/material.dart';

class OnlineDot extends StatelessWidget {
  final bool online;
  final double size;
  const OnlineDot({required this.online, this.size = 10});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: online ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}
