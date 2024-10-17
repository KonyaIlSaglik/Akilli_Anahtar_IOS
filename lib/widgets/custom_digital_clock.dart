import 'dart:async';

import 'package:akilli_anahtar/utils/custom_digital_clock_painter.dart';
import 'package:flutter/material.dart';

class CustomDigitalClock extends StatefulWidget {
  final DateTime? datetime;

  // final bool showNumbers;
  // final bool showAllNumbers;
  final bool showSeconds;
  final BoxDecoration? decoration;
  final Color digitalClockTextColor;
  final EdgeInsets? padding;
  final bool isLive;
  final double textScaleFactor;

  ///You can pass INTL date format skeleton here, to choose in what format you want to display the time. Note in case of ui distored please wrap it inside a container with desired padding and margin.
  ///For more info about skeletons please refer to this site https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html
  final String? format;

  const CustomDigitalClock(
      {this.format,
      this.datetime,
      this.showSeconds = true,
      this.decoration,
      this.padding,
      this.digitalClockTextColor = Colors.black,
      this.textScaleFactor = 1.0,
      isLive,
      super.key})
      : isLive = isLive ?? (datetime == null);
  const CustomDigitalClock.dark(
      {this.format,
      this.datetime,
      this.showSeconds = true,
      this.padding,
      this.decoration = const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(15))),
      this.digitalClockTextColor = Colors.white,
      this.textScaleFactor = 1.0,
      this.isLive = false,
      super.key});
  const CustomDigitalClock.light(
      {this.format,
      this.datetime,
      this.showSeconds = true,
      this.padding,
      this.decoration = const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(15))),
      this.digitalClockTextColor = Colors.black,
      this.textScaleFactor = 1.0,
      this.isLive = false,
      super.key});

  @override
  State<CustomDigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<CustomDigitalClock> {
  DateTime initialDatetime; // to keep track of time changes
  DateTime datetime;

  Duration updateDuration = const Duration(seconds: 1); // repaint frequency
  _DigitalClockState()
      : datetime = DateTime.now(),
        initialDatetime = DateTime.now();

  @override
  initState() {
    super.initState();

    updateDuration = Duration(seconds: 1);
    if (widget.isLive) {
      // update clock every second or minute based on second hand's visibility.

      Timer.periodic(updateDuration, update);
    }
  }

  update(Timer timer) {
    if (mounted) {
      // update is only called on live clocks. So, it's safe to update datetime.
      datetime = initialDatetime.add(updateDuration * timer.tick);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.decoration,
      padding: widget.padding,
      child: Container(
          constraints: BoxConstraints(
              minWidth: widget.showSeconds
                  ? 110 * widget.textScaleFactor
                  : 85.0 * widget.textScaleFactor,
              minHeight: 20.0 * widget.textScaleFactor),
          child: CustomPaint(
            painter: CustomDigitalClockPainter(
                format: widget.format,
                showSeconds: widget.showSeconds,
                datetime: datetime,
                digitalClockTextColor: widget.digitalClockTextColor,
                textScaleFactor: widget.textScaleFactor),
          )),
    );
  }

  @override
  void didUpdateWidget(CustomDigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.isLive && widget.datetime != oldWidget.datetime) {
      datetime = widget.datetime ?? DateTime.now();
    } else if (widget.isLive && widget.datetime != oldWidget.datetime) {
      initialDatetime = widget.datetime ?? DateTime.now();
    }
  }
}
