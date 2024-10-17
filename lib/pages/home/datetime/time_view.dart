import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_digital_clock.dart';
import 'package:flutter/material.dart';

class TimeView extends StatelessWidget {
  const TimeView({super.key});

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
        child: FittedBox(
          child: CustomDigitalClock(
            isLive: true,
            showSeconds: false,
            format: "HH:mm",
            digitalClockTextColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
