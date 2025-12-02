import 'dart:async';
import 'dart:convert';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/device_status_text.dart';
import 'package:akilli_anahtar/widgets/loading_dots.dart';
import 'package:akilli_anahtar/widgets/offline_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceListViewItemInfo extends StatefulWidget {
  final HomeDeviceDto device;
  const DeviceListViewItemInfo({super.key, required this.device});

  @override
  State<DeviceListViewItemInfo> createState() => _DeviceListViewItemInfoState();
}

class _DeviceListViewItemInfoState extends State<DeviceListViewItemInfo> {
  final MqttController _mqtt = Get.find();
  final HomeController _home = Get.find();

  late HomeDeviceDto device;
  String status = "";
  int alarmStatus = 0;

  bool _hasFirstData = false;
  Timer? _retainedCheckTimer;

  void Function(String topic, String payload)? _listenerRef;

  @override
  void initState() {
    super.initState();
    device = widget.device;

    _checkForExistingStatus();

    if (device.topicStat != null && device.topicStat!.isNotEmpty) {
      _mqtt.subscribeToTopic(device.topicStat!);

      _retainedCheckTimer = Timer(const Duration(milliseconds: 500), () {
        _checkForExistingStatus();
      });
    }

    status = _home.lastStatus[device.id!] ?? "";
    _hasFirstData = status.isNotEmpty;

    _listenerRef = (String topic, String payload) {
      if (!mounted) return;
      if (topic != device.topicStat) return;

      try {
        if (payload.isNotEmpty && payload.trimLeft().startsWith("{")) {
          final map = json.decode(payload);

          final dynamic raw = map["deger"];
          final String valueStr = (raw == null) ? "" : raw.toString();

          int newAlarm = 0;
          if (map.containsKey("alarm")) {
            final a = map["alarm"];
            if (a is int) newAlarm = a.clamp(0, 2);
            if (a is String) newAlarm = (int.tryParse(a) ?? 0).clamp(0, 2);
          } else {
            final dVal = double.tryParse(valueStr);
            if (dVal != null) {
              if (device.normalMaxValue != null &&
                  dVal >= device.normalMaxValue!) newAlarm = 1;
              if (device.criticalMaxValue != null &&
                  dVal >= device.criticalMaxValue!) newAlarm = 2;
            }
          }

          if (status != valueStr || alarmStatus != newAlarm) {
            setState(() {
              status = valueStr;
              alarmStatus = newAlarm;
              _hasFirstData = status.isNotEmpty || _hasFirstData;
            });
          }
          _home.lastStatus[device.id!] = valueStr;
        }
      } catch (_) {}
    };

    _mqtt.onMessage(_listenerRef!);
  }

  @override
  void dispose() {
    try {} catch (_) {}
    super.dispose();
  }

  void _checkForExistingStatus() {
    if (!mounted) return;
    final last = _mqtt.getDeviceLastStatus(device);
    print("Retained check for device ${device.id}: $last");
    if (last != null && last.isNotEmpty) {
      final parsed = _parsePayload(last);
      final valueStr = parsed.$1;
      final newAlarm = parsed.$2;

      if (valueStr.isEmpty && status.isNotEmpty) return;

      setState(() {
        status = valueStr;
        alarmStatus = newAlarm;
        _hasFirstData = status.isNotEmpty || _hasFirstData;
      });
      _home.lastStatus[device.id!] = valueStr;
    }
  }

  (String, int) _parsePayload(String payload) {
    try {
      final text = payload.trim();
      if (text.isEmpty) return ("", 0);

      if (text.startsWith("{")) {
        final map = json.decode(text) as Map<String, dynamic>;

        dynamic rawVal = map["deger"] ??
            map["value"] ??
            map["val"] ??
            (map["data"] is Map ? map["data"]["value"] : null);

        String valueStr = rawVal == null ? "" : rawVal.toString();

        // alarm
        int newAlarm = 0;
        if (map.containsKey("alarm")) {
          final a = map["alarm"];
          if (a is int) newAlarm = a.clamp(0, 2);
          if (a is String) newAlarm = (int.tryParse(a) ?? 0).clamp(0, 2);
        } else {
          final dVal = double.tryParse(valueStr.replaceAll(",", "."));
          if (dVal != null) {
            if (device.normalMaxValue != null && dVal >= device.normalMaxValue!)
              newAlarm = 1;
            if (device.criticalMaxValue != null &&
                dVal >= device.criticalMaxValue!) newAlarm = 2;
          }
        }
        return (valueStr, newAlarm);
      } else {
        final valueStr = text;
        int newAlarm = 0;
        final dVal = double.tryParse(valueStr.replaceAll(",", "."));
        if (dVal != null) {
          if (device.normalMaxValue != null && dVal >= device.normalMaxValue!)
            newAlarm = 1;
          if (device.criticalMaxValue != null &&
              dVal >= device.criticalMaxValue!) newAlarm = 2;
        }
        return (valueStr, newAlarm);
      }
    } catch (_) {
      return (payload, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool offline = _mqtt.isDeviceOffline(device);
      final bool connected = _mqtt.isConnected.value;
      final bool connecting = _mqtt.connecting.value;

      final bool forceLoading = (!_hasFirstData) && (connecting || !connected);

      final double opacity = offline ? 0.7 : 1.0;

      if (device.typeId == 3) {
        if (offline) {
          if (offline) {
            return Opacity(
              opacity: opacity,
              child: const OfflineWidget(),
            );
          }
        }
        return Opacity(
          opacity: opacity,
          child: Center(
            child: DeviceStatusText(
              device: device,
              alarm: alarmStatus,
              value: status,
              isLoading: !offline && forceLoading,
            ),
          ),
        );
      }

      return Opacity(
        opacity: opacity,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _buildBody(
              offline: offline, forceLoading: forceLoading, context: context),
        ),
      );
    });
  }

  Widget _buildBody({
    required bool offline,
    required bool forceLoading,
    required BuildContext context,
  }) {
    if (offline) {
      return const OfflineWidget();
    }

    if (forceLoading) {
      return const _LoadingCenter(key: ValueKey('loading'));
    }

    final String shown = status.isEmpty ? "—" : status;
    return _ValueWithUnit(
      key: ValueKey('value-$shown-$alarmStatus'),
      value: shown,
      unit: device.unit ?? "",
      valueStyle: valueStyle26(context, alarmStatus),
      unitStyle: unitStyle14(context, alarmStatus),
    );
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
  final Color color = switch (alarm) {
    2 => Colors.red,
    1 => Colors.orange,
    _ => Colors.black54,
  };
  return TextStyle(
    color: color,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}

class _ValueWithUnit extends StatelessWidget {
  final String value;
  final String unit;
  final TextStyle? valueStyle;
  final TextStyle? unitStyle;

  const _ValueWithUnit({
    super.key,
    required this.value,
    required this.unit,
    this.valueStyle,
    this.unitStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(value, style: valueStyle),
        const SizedBox(width: 6),
        Text(unit, style: unitStyle),
      ],
    );
  }
}

class _LoadingCenter extends StatelessWidget {
  const _LoadingCenter({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: LoadingDots());
  }
}
