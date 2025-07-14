import 'package:flutter/material.dart';

class DeviceCardWidget extends StatelessWidget {
  final Widget? leftTop;
  final Widget? rightTop;
  final Widget? body;
  final Widget? title;
  final double size;

  const DeviceCardWidget({
    super.key,
    required this.leftTop,
    required this.rightTop,
    required this.body,
    required this.title,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.all(size * 0.02),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                leftTop!,
                rightTop!,
              ],
            ),
            SizedBox(height: size * 0.02),
            body!,
            SizedBox(height: size * 0.02),
            title!,
          ],
        ),
      ),
    );
  }
}
