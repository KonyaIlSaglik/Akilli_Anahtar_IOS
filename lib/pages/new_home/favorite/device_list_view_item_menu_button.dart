import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
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
    return InkWell(
      child: PopupMenuButton(
        splashRadius: 40,
        child: SizedBox(
          width: width(context) * 0.1,
          height: height(context) * 0.03,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.more_vert,
              ),
            ],
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            height: height(context) * 0.04,
            child: Text(
              widget.device.favoriteSequence != null
                  ? "Favorilerden Çıkar"
                  : "Favorilere EKle",
              style: textTheme(context).labelLarge,
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
              height: height(context) * 0.04,
              child: Text(
                "Yeniden Adlandır",
                style: textTheme(context).labelLarge,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    var controller = TextEditingController();
                    return AlertDialog(
                      title: Text("Yeniden Adlandır"),
                      content: Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: "Yeni ad",
                            hintStyle: TextStyle(color: Colors.grey),
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
                          onPressed: () {
                            Get.back();
                          },
                          child: Text("Vazgeç"),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (controller.text !=
                                  widget.device.favoriteName!) {
                                HomeController homeController = Get.find();
                                await homeController.updateFavoriteName(
                                    widget.device.id!, controller.text);
                              }
                              Get.back();
                            }
                          },
                          child: Text("Kaydet"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          if (widget.device.typeId! < 4)
            PopupMenuItem(
              height: height(context) * 0.04,
              child: Text(
                notificationEnable ? "Bildirimleri Kapat" : "Bildirimleri Aç",
                style: textTheme(context).labelLarge,
              ),
              onTap: () async {
                notificationEnable = !notificationEnable;
                await LocalDb.add(notificationKey(widget.device.id!),
                    notificationEnable ? "1" : "0");
              },
            ),
          if (widget.device.typeId! > 3)
            PopupMenuItem(
              height: height(context) * 0.04,
              child: Text(
                "Planla",
                style: textTheme(context).labelLarge,
              ),
              onTap: () {
                //
              },
            ),
          if (widget.device.typeId! > 3)
            PopupMenuItem(
              height: height(context) * 0.04,
              child: Text(
                "Konum Etkinleştir",
                style: textTheme(context).labelLarge,
              ),
              onTap: () {
                //
              },
            ),
        ],
      ),
    );
  }
}
