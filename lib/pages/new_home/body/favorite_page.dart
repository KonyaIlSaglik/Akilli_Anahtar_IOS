import 'package:akilli_anahtar/controllers/home_controller.dart';
import 'package:akilli_anahtar/pages/new_home/body/vertical_list.dart';
import 'package:akilli_anahtar/widgets/custom_device_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    return Column(
      children: [
        VerticalList(
          listTitle: "Favoriler",
          titleOnPressed: () {
            //
          },
          items: homeController.favoriteDevices.map(
            (d) {
              return CustomDeviceCard(
                device: d,
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}
