import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/back_container.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class FavoriteEditPage extends StatefulWidget {
  const FavoriteEditPage({super.key});

  @override
  State<FavoriteEditPage> createState() => _FavoriteEditPageState();
}

class _FavoriteEditPageState extends State<FavoriteEditPage> {
  HomeController homeController = Get.find();

  late List<HomeDeviceDto> favorites;
  late List<HomeDeviceDto> others;

  @override
  void initState() {
    super.initState();
    favorites = homeController.homeDevices
        .where((d) => d.favoriteSequence! > -1)
        .toList();
    others = homeController.homeDevices
        .where((d) => d.favoriteSequence == -1)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[50]!,
        foregroundColor: Colors.brown[50]!,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          size: 30,
        ),
        title: Text(
          "Favorileri Düzenle",
          style: width(context) < minWidth
              ? textTheme(context).titleMedium!
              : textTheme(context).titleLarge!,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor.withOpacity(0.7),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                for (var d in favorites) {
                  await homeController.updateFavoriteSequence(
                      d.id!, d.favoriteSequence!);
                }
                for (var d in others) {
                  await homeController.updateFavoriteSequence(d.id!, -1);
                }
                Get.back();
              },
              child: Text("Kaydet"),
            ),
          ),
        ],
      ),
      body: BackContainer(
        child: Column(
          children: [
            SizedBox(
              height: height(context) * 0.01,
            ),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: ReorderableGridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 2,
                      dragWidgetBuilder: (index, child) {
                        return child;
                      },
                      children: favorites
                          .map(
                            (e) => Stack(
                              key: ValueKey(e.id),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DeviceListViewItem(
                                    device: e,
                                    active: false,
                                  ) as Widget,
                                ),
                                Positioned(
                                  right: -8,
                                  top: -8,
                                  child: Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.brown[50],
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                    child: IconButton(
                                      color: Colors.white,
                                      onPressed: () {
                                        setState(() {
                                          favorites
                                              .removeWhere((d) => d.id == e.id);
                                          e.favoriteSequence = -1;
                                        });
                                        setState(() {
                                          others.add(e);
                                        });
                                      },
                                      icon: Icon(
                                        FontAwesomeIcons.circleMinus,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          final element = favorites.removeAt(oldIndex);
                          favorites.insert(newIndex, element);
                          for (int i = 0; i < favorites.length; i++) {
                            var device = homeController.devices
                                .firstWhere((d) => d.id == favorites[i].id);
                            device.favoriteSequence = i;
                          }
                        });
                      },
                    ),
                  ),
                  DraggableScrollableSheet(
                    maxChildSize: 0.9,
                    minChildSize: 0.3,
                    builder: (BuildContext context, scrollController) {
                      return Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                        ),
                        child: CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            SliverAppBar(
                              pinned: true,
                              automaticallyImplyLeading: false,
                              centerTitle: true,
                              toolbarHeight: 25,
                              backgroundColor: Colors.white,
                              surfaceTintColor: Colors.white,
                              primary: true,
                              title: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).hintColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  height: 4,
                                  width: 40,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            if (others.isNotEmpty)
                              SliverPadding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                sliver: SliverGrid.builder(
                                  itemCount: others.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 3 / 2,
                                  ),
                                  itemBuilder: (context, index) {
                                    var e = others[index];
                                    return Stack(
                                      clipBehavior: Clip.hardEdge,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DeviceListViewItem(
                                            device: e,
                                            active: false,
                                          ) as Widget,
                                        ),
                                        Positioned(
                                          right: -8,
                                          top: -8,
                                          child: Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(60),
                                            ),
                                            child: IconButton(
                                              color: Colors.white,
                                              onPressed: () {
                                                setState(() {
                                                  others.removeWhere(
                                                      (d) => d.id == e.id);
                                                  e.favoriteSequence =
                                                      favorites.length;
                                                });
                                                setState(() {
                                                  favorites.add(e);
                                                });
                                              },
                                              icon: Icon(
                                                FontAwesomeIcons.circlePlus,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
