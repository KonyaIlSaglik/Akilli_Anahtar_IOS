import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/favorite_page_edit_button.dart';
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
  late List<Widget> items;

  @override
  void initState() {
    super.initState();

    items = homeController.favoriteDevices
        .map(
          (e) => DeviceListViewItem(
            device: e,
          ) as Widget,
        )
        .toList();
    items.insert(0, FavoritePageEditButton());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfilCard(),
        SizedBox(height: height(context) * 0.02),
        Expanded(
          child: GridView(
            reverse: true,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
            ),
            children: items,
          ),
        ),
      ],
    );
  }
}
