import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/profil_card.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  HomeController homeController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Column(
          children: [
            ProfilCard(),
            SizedBox(height: height(context) * 0.02),
            Expanded(
              child: ReorderableGridView.count(
                reverse: true,
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                dragWidgetBuilder: (index, child) {
                  return child;
                },
                children: homeController.favorites
                    .map((d) =>
                        DeviceListViewItem(key: ValueKey(d.id), device: d))
                    .toList(),
                onReorder: (oldIndex, newIndex) async {
                  final element = homeController.favorites.removeAt(oldIndex);
                  homeController.favorites.insert(newIndex, element);
                  for (int i = 0; i < homeController.favorites.length; i++) {
                    if (homeController.favorites[i].favoriteSequence != i) {
                      homeController.favorites[i].favoriteSequence = i;
                      await homeController.updateFavoriteSequence(
                          homeController.favorites[i].id!,
                          homeController.favorites[i].favoriteSequence!);
                    }
                  }
                },
              ),
            ),
            SizedBox(height: height(context) * 0.03),
          ],
        );
      },
    );
  }
}
