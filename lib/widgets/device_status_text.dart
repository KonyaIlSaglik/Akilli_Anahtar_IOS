import 'package:akilli_anahtar/dtos/home_device_dto.dart';

import 'package:akilli_anahtar/widgets/loading_dots.dart';
import 'package:flutter/material.dart';

class DeviceStatusText extends StatelessWidget {
  final HomeDeviceDto device;
  final int? alarm;
  final String? value;

  final bool isLoading;

  const DeviceStatusText({
    Key? key,
    required this.device,
    required this.alarm,
    required this.value,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool noDataYet = (alarm == null || value == null);

    if (isLoading || noDataYet) {
      return const Center(child: LoadingDots());
    }

    if (device.typeId == 3) {
      String alarmText;
      Color alarmColor;

      if (alarm == 2) {
        alarmText = "Yangın Riski!";
        alarmColor = Colors.red;
      } else if (alarm == 1) {
        alarmText = "Yangın Uyarısı";
        alarmColor = Colors.orange;
      } else {
        alarmText = "Alarm Yok";
        alarmColor = Colors.black87;
      }

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              alarmText,
              textAlign: TextAlign.center,
              style: valueStyle26(context, alarm!),
            ),
            Text(
              "Hava Kalitesi: $value",
              style: unitStyle14(context, alarm!),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Hava Kalitesi:",
              style: TextStyle(color: Colors.black),
            ),
            Text(
              value!,
              style: unitStyle14(context, alarm!),
            ),
          ],
        ),
      );
    }
  }
}

TextStyle valueStyle26(BuildContext context, int alarm) {
  final Color color = switch (alarm) {
    2 => Colors.red,
    1 => Colors.orange,
    _ => Colors.black87,
  };
  return TextStyle(
    color: color,
    fontSize: 26,
    fontWeight: FontWeight.w500,
  );
}

TextStyle unitStyle14(BuildContext context, int alarm) {
  final bool isAlarm = alarm == 1 || alarm == 2;
  return TextStyle(
    color: isAlarm ? (alarm == 2 ? Colors.red : Colors.orange) : Colors.black54,
    fontSize: 14,
  );
}
