import 'package:flutter/material.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';

class TimeView extends StatelessWidget {
  const TimeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(0.80)),
      child: DigitalClock(
        showSecondsDigit: false,
        is24HourTimeFormat: true,
        hourMinuteDigitTextStyle: TextStyle(
          color: Colors.white,
          fontSize: Theme.of(context).textTheme.displayLarge!.fontSize,
          fontWeight: FontWeight.bold,
        ),
        colon: Text(
          ":",
          style: TextStyle(
            color: Colors.white,
            fontSize: Theme.of(context).textTheme.displayLarge!.fontSize,
          ),
        ),
      ),
    );
  }
}
