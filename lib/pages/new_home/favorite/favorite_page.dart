import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/models/device_group_by_box.dart';
import 'package:akilli_anahtar/pages/new_home/card_devices/device_grid_list.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/profil_card.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return ListView(
          children: [
            SizedBox(height: height(context) * 0.02),
            ProfilCard(),
            SizedBox(height: height(context) * 0.01),
            DeviceGridList(
              deviceGroup: DeviceGroupByBox(
                  boxName: "Favoriler",
                  devices: homeController.favoriteDevices),
            )
          ],
        );
      },
    );
  }
}
