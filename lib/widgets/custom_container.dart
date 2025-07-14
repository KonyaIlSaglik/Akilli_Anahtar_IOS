import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget body;
  final int flex;
  const CustomContainer({super.key, required this.body, this.flex = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(flex: flex, child: SizedBox(width: 0)),
        Expanded(
          flex: 100 - (flex * 2),
          child: body,
        ),
        Expanded(flex: flex, child: SizedBox(width: 0)),
      ],
    );
  }
}
