import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:one_clock/one_clock.dart';

class DateView extends StatelessWidget {
  const DateView({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * 0.95,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: goldColor,
        child: DigitalClock(
          isLive: true,
          showSeconds: false,
          format: "dd MMMM yyyy EEEE",
          digitalClockTextColor: Colors.white,
        ),
      ),
    );
  }
}
