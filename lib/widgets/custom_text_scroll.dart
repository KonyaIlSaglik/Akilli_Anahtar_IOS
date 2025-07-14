import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

class CustomTextScroll extends StatelessWidget {
  final String text;

  CustomTextScroll({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(),
      child: TextScroll(
        text,
        mode: TextScrollMode.bouncing,
        velocity: Velocity(pixelsPerSecond: Offset(10, 0)),
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.right,
        selectable: false,
      ),
    );
  }
}
