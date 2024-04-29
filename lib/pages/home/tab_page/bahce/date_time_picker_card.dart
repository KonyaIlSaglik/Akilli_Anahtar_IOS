import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants.dart';

class DateTimePickerCard extends StatefulWidget {
  final String title;
  final Function(DateTime date) onSelected;
  const DateTimePickerCard({
    Key? key,
    required this.title,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<DateTimePickerCard> createState() => _DateTimePickerCardState();
}

class _DateTimePickerCardState extends State<DateTimePickerCard> {
  DateTime selected = DateTime.now();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: Card(
        elevation: 3,
        shadowColor: mainColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Text(widget.title),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 70,
                    child: InkWell(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 20,
                            child: Icon(
                              Icons.calendar_month,
                              color: mainColor,
                            ),
                          ),
                          Expanded(
                            flex: 80,
                            child: Text(
                              formatDate(selected),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        _selectDate(context);
                      },
                    ),
                  ),
                  Expanded(
                    flex: 30,
                    child: InkWell(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 30,
                            child: Icon(
                              Icons.access_time_outlined,
                              color: mainColor,
                            ),
                          ),
                          Expanded(
                            flex: 50,
                            child: Text(
                              formatTime(selected),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        _selectTime(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2025),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
                primary: mainColor, // <-- SEE HERE
                onPrimary: Colors.white, // <-- SEE HERE
                onSurface: Colors.black // <-- SEE HERE
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selected = picked;
      });
      _selectTime(context);
    }
  }

  Future<void> _selectTime(context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
                primary: mainColor, // <-- SEE HERE
                onPrimary: Colors.white, // <-- SEE HERE
                onSurface: Colors.black // <-- SEE HERE
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selected = DateTime(
          selected.year,
          selected.month,
          selected.day,
          picked.hour,
          picked.minute,
        );
      });
      widget.onSelected(selected);
    }
  }

  String formatDate(DateTime dateTime) {
    return DateFormat("dd.MM.yyyy EEEE", "tr").format(dateTime);
  }

  String formatTime(DateTime dateTime) {
    return DateFormat("HH:mm", "tr").format(dateTime);
  }
}
