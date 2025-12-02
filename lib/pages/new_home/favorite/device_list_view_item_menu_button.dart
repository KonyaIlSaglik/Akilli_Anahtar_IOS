import 'package:akilli_anahtar/controllers/main/home_controller.dart';

import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';

import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_plan_add.dart';

import 'package:akilli_anahtar/pages/new_home/setting/box_management/share_code_page.dart';

import 'package:akilli_anahtar/services/local/shared_prefences.dart';

import 'package:akilli_anahtar/utils/constants.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DeviceListViewItemMenuButton extends StatefulWidget {
  final HomeDeviceDto device;

  const DeviceListViewItemMenuButton({
    super.key,
    required this.device,
  });

  @override
  State<DeviceListViewItemMenuButton> createState() =>
      _DeviceListViewItemMenuButtonState();
}

class _DeviceListViewItemMenuButtonState
    extends State<DeviceListViewItemMenuButton> {
  final _formKey = GlobalKey<FormState>();
  MqttController mqtt = Get.find<MqttController>();

  final authController = Get.find<AuthController>();

  bool notificationEnable = false;

  @override
  void initState() {
    super.initState();

    LocalDb.get(notificationKey(widget.device.id!)).then(
      (value) {
        notificationEnable = value == null || value == "1";
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      splashRadius: 40,
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: const Icon(Icons.more_vert, color: Colors.black87),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          height: height(context) * 0.045,
          child: Row(
            children: [
              Icon(
                  widget.device.favoriteSequence != null
                      ? Icons.star
                      : Icons.star_border,
                  size: 20,
                  color: primaryDarkBlue),
              const SizedBox(width: 10),
              Text(
                widget.device.favoriteSequence != null
                    ? "Favorilerden Çıkar"
                    : "Favorilere Ekle",
                style: textTheme(context).labelLarge,
              ),
            ],
          ),
          onTap: () async {
            HomeController homeController = Get.find();

            await homeController.updateFavoriteSequence(
              widget.device.id!,
              widget.device.favoriteSequence != null
                  ? 0
                  : homeController.getNextFavoriteSequence(),
            );
          },
        ),
        if (widget.device.favoriteSequence != null)
          PopupMenuItem(
            value: 2,
            height: height(context) * 0.045,
            child: Row(
              children: [
                const Icon(Icons.edit, size: 20, color: mediumBlue),
                const SizedBox(width: 10),
                Text("Yeniden Adlandır", style: textTheme(context).labelLarge),
              ],
            ),
            onTap: () {
              var controller = TextEditingController();

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Yeniden Adlandır"),
                    content: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: "Yeni ad",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Boş olamaz";
                          }

                          return null;
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: Get.back, child: const Text("Vazgeç")),
                      TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (controller.text != widget.device.favoriteName) {
                              HomeController homeController = Get.find();

                              await homeController.updateFavoriteName(
                                  widget.device.id!, controller.text);
                            }

                            Get.back();
                          }
                        },
                        child: const Text("Kaydet"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        if (widget.device.typeId! < 4)
          PopupMenuItem(
            value: 3,
            height: height(context) * 0.045,
            child: Row(
              children: [
                Icon(
                    notificationEnable
                        ? Icons.notifications_off
                        : Icons.notifications,
                    size: 20,
                    color: grayNeutral),
                const SizedBox(width: 10),
                Text(
                  notificationEnable ? "Bildirimleri Kapat" : "Bildirimleri Aç",
                  style: textTheme(context).labelLarge,
                ),
              ],
            ),
            onTap: () async {
              notificationEnable = !notificationEnable;

              if (notificationEnable) {
                await LocalDb.delete(notificationKey(widget.device.id!));
              } else {
                await LocalDb.add(notificationKey(widget.device.id!), "0");
              }
            },
          ),
        if (!mqtt.isDeviceOffline(widget.device) &&
            (widget.device.typeId == 5 ||
                widget.device.typeId == 8 ||
                widget.device.typeId == 10))
          PopupMenuItem(
            value: 5,
            height: height(context) * 0.045,
            child: Row(
              children: [
                const Icon(Icons.schedule, size: 20, color: Colors.teal),
                const SizedBox(width: 10),
                Text("Plan Ekle", style: textTheme(context).labelLarge),
              ],
            ),
            onTap: () {
              Get.to(() => PlanAddEditPage(device: widget.device));
            },
          ),
        if (authController.adminDeviceIds.contains(widget.device.id))
          PopupMenuItem(
            value: 4,
            height: height(context) * 0.045,
            child: Row(
              children: [
                const Icon(Icons.share, size: 20, color: Colors.red),
                const SizedBox(width: 10),
                const Text("Paylaş",
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            onTap: () {
              Get.to(() => ShareCodePage(deviceId: widget.device.id!));
            },
          ),
      ],
    );
  }
}
