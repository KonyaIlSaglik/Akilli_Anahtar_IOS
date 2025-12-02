import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class OpenDoorButton extends StatelessWidget {
  final HomeDeviceDto device;
  final double size;
  const OpenDoorButton({super.key, required this.device, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final mqtt = Get.find<MqttController>();

    return Obx(() {
      final offline = mqtt.isDeviceOffline(device);

      return Tooltip(
        message: offline ? 'Cihaz offline' : 'Aç',
        child: ElevatedButton(
          onPressed: offline ? null : () => _sendOpen(mqtt),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            fixedSize: Size(size, size),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.red.shade300,
            disabledForegroundColor: Colors.white70,
            elevation: 3,
            shadowColor: Colors.red.withOpacity(0.35),
          ),
          child: const Icon(Icons.lock_open_rounded, size: 24),
        ),
      );
    });
  }

  void _sendOpen(MqttController mqtt) {
    if (!mqtt.isConnected.value || device.topicRec == null) return;

    if ((device.boxName?.toLowerCase().contains("şehir sitesi garaj") ??
            false) &&
        (device.name?.toLowerCase().contains("box-2") ?? false)) return;

    HapticFeedback.mediumImpact();

    if (device.typeId == 6 &&
        device.rfCodes != null &&
        device.rfCodes!.isNotEmpty) {
      mqtt.publishMessage(device.topicRec!, device.rfCodes![0]);
    } else {
      mqtt.publishMessage(device.topicRec!, "0");
    }
  }
}
