import 'package:flutter/material.dart';

class OfflineWidget extends StatelessWidget {
  final String message;

  final bool center;

  final EdgeInsetsGeometry? padding;

  final TextStyle? style;

  const OfflineWidget({
    super.key,
    this.message = "Veri Alınamadı",
    this.center = true,
    this.padding,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(
      message,
      style: style ??
          const TextStyle(
            color: Color(0xCCF44336),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
    );

    final child =
        padding != null ? Padding(padding: padding!, child: text) : text;

    if (center) {
      return Center(child: child);
    }
    return child;
  }
}
