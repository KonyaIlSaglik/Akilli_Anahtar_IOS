import 'package:flutter/material.dart';

class ConnectionErrorWidget extends StatelessWidget {
  final String message;
  final double fontSize;
  final Color? color;

  const ConnectionErrorWidget({
    super.key,
    this.message = "Cihaza bağlanılamadı",
    this.fontSize = 12.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        color: color ?? Colors.red[800],
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
