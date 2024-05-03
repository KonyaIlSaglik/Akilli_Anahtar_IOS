import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class DateView extends StatelessWidget {
  const DateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var fontSize = height > 768
        ? Theme.of(context).textTheme.headlineMedium!.fontSize!
        : Theme.of(context).textTheme.headlineSmall!.fontSize!;
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      color: mainColor,
      child: Text(
        DateFormat("dd MMMM yyyy EEEE", "tr_TR").format(DateTime.now()),
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
