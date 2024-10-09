import 'package:akilli_anahtar/pages/home/datetime/date_view.dart';
import 'package:akilli_anahtar/pages/home/datetime/time_view.dart';
import 'package:flutter/material.dart';

class DatetimeView extends StatelessWidget {
  const DatetimeView({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: height * 0.12,
          child: DateView(),
        ),
        Positioned(
          top: 0,
          child: TimeView(),
        ),
      ],
    );
  }
}
