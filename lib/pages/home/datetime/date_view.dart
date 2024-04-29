import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateView extends StatelessWidget {
  const DateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(0.80)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat("dd MMMM yyyy", "tr_TR").format(DateTime.now()),
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat("EEEE", "tr_TR").format(DateTime.now()),
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
