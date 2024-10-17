import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class CustomDigitalClockPainter extends CustomPainter {
  DateTime datetime;
  final String? format;
  final Color digitalClockTextColor;
  final double textScaleFactor;
  final TextStyle? textStyle;
  //digital clock
  final bool showSeconds;

  CustomDigitalClockPainter({
    required this.datetime,
    this.textStyle,
    this.format,
    this.showSeconds = true,
    this.digitalClockTextColor = Colors.black,
    this.textScaleFactor = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double scaleFactor = 1;

    _paintDigitalClock(canvas, size, scaleFactor);
  }

  @override
  bool shouldRepaint(CustomDigitalClockPainter oldDelegate) {
    return oldDelegate.datetime.isBefore(datetime);
  }

  void _paintDigitalClock(Canvas canvas, Size size, double scaleFactor) {
    String textToBeDisplayed = (!(format?.isEmpty ?? true))
        ? intl.DateFormat(format, "tr-TR").format(datetime)
        : showSeconds
            ? intl.DateFormat('h:mm:ss a', "tr-TR").format(datetime)
            : intl.DateFormat('h:mm a', "tr-TR").format(datetime);
    TextSpan digitalClockSpan = TextSpan(
        style: textStyle ??
            TextStyle(
                color: digitalClockTextColor,
                fontSize: 18 * scaleFactor * textScaleFactor,
                fontWeight: FontWeight.bold),
        text: textToBeDisplayed);
    TextPainter digitalClockTP = TextPainter(
        text: digitalClockSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    digitalClockTP.layout();
    digitalClockTP.paint(
        canvas, size.center(-digitalClockTP.size.center(Offset(0.0, 0.0))));
  }
}
