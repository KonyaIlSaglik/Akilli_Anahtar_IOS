import 'package:flutter/material.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';

class TimeView extends StatelessWidget {
  const TimeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var fontSize = height > 768
        ? Theme.of(context).textTheme.displayLarge!.fontSize! * 1.5
        : Theme.of(context).textTheme.displayLarge!.fontSize!;
    return Container(
      width: MediaQuery.of(context).size.width,
      child: DigitalClock(
        showSecondsDigit: false,
        is24HourTimeFormat: true,
        hourMinuteDigitTextStyle: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        colon: Text(
          ":",
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
