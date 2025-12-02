import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item_action.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item_info.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item_menu_button.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item_switch.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/online_dot_widget.dart';
import 'package:akilli_anahtar/widgets/open_door_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceListViewItem extends StatefulWidget {
  final HomeDeviceDto device;
  const DeviceListViewItem({super.key, required this.device});

  @override
  State<DeviceListViewItem> createState() => _DeviceListViewItemState();
}

class _DeviceListViewItemState extends State<DeviceListViewItem>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final MqttController _mqtt = Get.find();
  final HomeController _home = Get.find();
  late HomeDeviceDto device;

  @override
  bool get wantKeepAlive => true;

  late final AnimationController _borderController;

  @override
  void initState() {
    super.initState();
    device = widget.device;

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  void _flashBorderFor2s() async {
    if (!mounted) return;
    setState(() => _showBorder = true);
    _borderController.repeat(period: const Duration(seconds: 5));

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    _borderController.stop();
    setState(() => _showBorder = false);
  }

  bool get _supportsTapToSend {
    final t = device.typeId;
    return t == 4 || t == 6 || t == 9;
  }

  bool _showBorder = false;

  void showRotatingBorder() async {
    if (!mounted) return;
    setState(() => _showBorder = true);
    _borderController.repeat(period: const Duration(seconds: 5));

    await Future.delayed(const Duration(seconds: 5));
    _borderController.stop();
    if (mounted) {
      _borderController.stop();
      setState(() => _showBorder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final bool offline = _mqtt.isDeviceOffline(device);

      final gradientColors = [
        Colors.brown[50]!,
        Colors.brown[50]!,
        Colors.brown[100]!,
        Colors.brown[200]!,
      ];

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: gradientColors,
                  ),
                ),
              ),
            ),
            if (offline)
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.05)),
              ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Opacity(
                opacity: 0.18,
                child: Icon(
                  deviceIcon(device.typeId!),
                  size: 30,
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 6,
              right: 40,
              child: Row(
                children: [
                  OnlineDot(online: !offline, size: 10),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      capitalizeWords(device.favoriteName ?? device.name) ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: textTheme(context).labelLarge?.copyWith(
                            color: (textTheme(context).labelLarge?.color ??
                                    Colors.black)
                                .withOpacity(offline ? 0.7 : 1),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Center(
                child: device.typeId == 1 ||
                        device.typeId == 2 ||
                        device.typeId == 3
                    ? DeviceListViewItemInfo(device: device)
                    : device.typeId == 4 || device.typeId == 6
                        ? DeviceListViewItemAction(
                            device: device,
                            onPowerTap: _flashBorderFor2s,
                          )
                        : DeviceListViewItemSwitch(device: device),
              ),
            ),
            Positioned(
              right: 0,
              top: 5,
              child: DeviceListViewItemMenuButton(device: device),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, left: 8, bottom: 4),
                child: Text(
                  capitalizeWords(device.boxName) ?? "",
                  style: textTheme(context).bodySmall?.copyWith(
                        color: (textTheme(context).bodySmall?.color ??
                                Colors.black87)
                            .withOpacity(offline ? 0.75 : 1),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (_supportsTapToSend)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: offline ? null : sendMessage,
                    splashColor:
                        Theme.of(context).primaryColor.withOpacity(0.08),
                    highlightColor: Colors.transparent,
                  ),
                ),
              ),
            Positioned(
              right: 0,
              top: 5,
              child: DeviceListViewItemMenuButton(device: device),
            ),
            if (_showBorder)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _borderController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: RotatingBorderPainter(_borderController.value),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    });
  }

  void sendMessage() {
    if (!_mqtt.isConnected.value || _mqtt.connecting.value) return;

    if ((device.boxName?.toLowerCase().contains("şehir sitesi garaj") ??
            false) &&
        (device.name?.toLowerCase().contains("box-2") ?? false)) {
      debugPrint("Özel cihaz: ${device.boxName}/${device.name} - atlandı");
      return;
    }

    if (device.typeId == 4) {
      _mqtt.publishMessage(device.topicRec!, "0");
    } else if (device.typeId == 5) {
      _mqtt.publishMessage(
        device.topicRec!,
        _home.lastStatus[device.id] == "1" ? "0" : "1",
      );
    } else if (device.typeId == 6) {
      if (device.rfCodes == null || device.rfCodes!.isEmpty) {
        debugPrint("RF codes list is empty for device ${device.name}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bu cihaz için RF kodu ayarlanmalı.")),
        );
        return;
      }
      _mqtt.publishMessage(device.topicRec!, device.rfCodes!.first);
    }
    // else if (device.typeId == 8) {
    //   _mqtt.publishMessage(device.topicRec!, "0");
    // }
    else if (device.typeId == 9) {
      _mqtt.publishMessage(
        device.topicRec!,
        _home.lastStatus[device.id] == "1" ? "0" : "1",
      );
    } else if (device.typeId == 10) {
      _mqtt.publishMessage(
        device.topicRec!,
        _home.lastStatus[device.id] == "1" ? "0" : "1",
      );
    }
    if (device.typeId == 4 || device.typeId == 6) {
      showRotatingBorder();
    }
  }
}

class RotatingBorderPainter extends CustomPainter {
  final double progress;
  RotatingBorderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final sweep = 2 * 3.14159 * progress;

    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 6.28318,
      colors: [
        Colors.greenAccent.shade100,
        Colors.white,
        Colors.green.shade700,
        Colors.white,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
      transform: GradientRotation(sweep),
    );

    final glowPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final borderPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..blendMode = BlendMode.srcOver;

    final rRect =
        RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(12));

    canvas.drawRRect(rRect, glowPaint);
    canvas.drawRRect(rRect, borderPaint);
  }

  @override
  bool shouldRepaint(RotatingBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
