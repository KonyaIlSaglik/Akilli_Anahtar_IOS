import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/profil_card.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/loading_dots.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  HomeController homeController = Get.find();
  bool visible = false;

  @override
  void initState() {
    super.initState();
    print("FavoritePage");
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return RefreshIndicator(
          onRefresh: () async {
            await homeController.getDevices();
          },
          child: Column(
            children: [
              SizedBox(height: height(context) * 0.01),
              ProfilCard(min: visible),
              Visibility(
                visible: visible,
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.warning),
                    subtitle: Text(
                      "Burada bildiirimler. Burada bildiirimler gösterilecektir.Burada bildiirimler gösterilecektir.",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    trailing: InkWell(
                      onTap: () {
                        //
                      },
                      child: Icon(FontAwesomeIcons.xmark),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height(context) * 0.02),
              Expanded(
                child: ReorderableGridView.count(
                  reverse: homeController.favorites.length < 3,
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: width(context) * 0.02,
                  mainAxisSpacing: width(context) * 0.02,
                  childAspectRatio: 3 / 2,
                  dragWidgetBuilder: (index, child) {
                    return child;
                  },
                  children: homeController.favorites
                      .map((d) => DeviceListViewItem(
                          key: ValueKey(
                              "${d.id}_${homeController.refreshTimestamp.value}"),
                          device: d))
                      .toList(),
                  onReorder: (oldIndex, newIndex) async {
                    final element = homeController.favorites.removeAt(oldIndex);
                    homeController.favorites.insert(newIndex, element);
                    for (var i = 0; i < homeController.favorites.length; i++) {
                      if (homeController.homeDevices
                              .singleWhere(
                                  (d) => d.id == homeController.favorites[i].id)
                              .favoriteSequence !=
                          i + 1) {
                        homeController.homeDevices
                            .singleWhere(
                                (d) => d.id == homeController.favorites[i].id)
                            .favoriteSequence = i + 1;
                      }
                    }
                    homeController.loadFavorites();
                    for (var d in homeController.favorites) {
                      homeController.updateFavoriteSequence(
                          d.id!, d.favoriteSequence!);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
