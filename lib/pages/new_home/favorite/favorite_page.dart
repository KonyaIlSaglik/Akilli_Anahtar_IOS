import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item.dart';
import 'package:akilli_anahtar/services/api/management_service.dart';
import 'package:akilli_anahtar/widgets/info_card.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/profil_card.dart';
import 'package:akilli_anahtar/pages/new_home/setting/box_management/add_box_onboarding_page.dart';
import 'package:akilli_anahtar/pages/new_home/setting/box_management/add_box_with_chipId.dart';
import 'package:akilli_anahtar/pages/new_home/setting/box_management/use_code_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:akilli_anahtar/pages/new_home/device/empty_device_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  HomeController homeController = Get.find();
  bool visible = false;
  bool emptyGuard = false;

  @override
  void initState() {
    super.initState();
    print("FavoritePage");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await homeController.getDevices();
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => emptyGuard = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = homeController.loading.value;
      final hasDevices = homeController.homeDevices.isNotEmpty;
      final items = homeController.favorites.isNotEmpty
          ? homeController.favorites
          : homeController.homeDevices;

      return RefreshIndicator(
        onRefresh: () => homeController.getDevices(),
        child: Column(
          children: [
            SizedBox(height: height(context) * 0.00),
            const InfoCard(),
            ProfilCard(min: visible),
            SizedBox(height: height(context) * 0.00),
            Expanded(
              child: () {
                if (isLoading && !hasDevices) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!isLoading && !hasDevices) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 8),
                    child: EmptyDeviceCompact(
                      onAdd: () async {
                        await Get.to(() =>
                            const AddBoxOnboardingPage(allowSkipExit: true));
                        await Get.to(() => const AddBoxByChipIdPage());
                        await homeController.getDevices();
                      },
                      onJoin: (String code) async {
                        print("Girilen kod: $code");
                        final result =
                            await ManagementService.useShareCode(code);
                        if (result != null) {
                          successSnackbar("Başarılı", "Cihaz eklendi.");
                          await homeController.getDevices();
                        } else {
                          errorSnackbar("Hata", "Cihaz eklenemedi.");
                        }
                      },
                    ),
                  );
                }
                return ReorderableGridView.count(
                  reverse: items.length < 3,
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: width(context) * 0.02,
                  mainAxisSpacing: width(context) * 0.02,
                  childAspectRatio: 3 / 2,
                  dragWidgetBuilder: (i, child) => child,
                  children: items
                      .map((d) => DeviceListViewItem(
                            key: ValueKey(
                                "${d.id}_${homeController.refreshTimestamp.value}"),
                            device: d,
                          ))
                      .toList(),
                  onReorder: (oldIndex, newIndex) async {
                    final el = homeController.favorites.removeAt(oldIndex);
                    homeController.favorites.insert(newIndex, el);
                    for (var i = 0; i < homeController.favorites.length; i++) {
                      final dev = homeController.homeDevices.singleWhere(
                          (x) => x.id == homeController.favorites[i].id);
                      if (dev.favoriteSequence != i + 1) {
                        dev.favoriteSequence = i + 1;
                      }
                    }
                    homeController.loadFavorites();
                    for (var d in homeController.favorites) {
                      homeController.updateFavoriteSequence(
                          d.id!, d.favoriteSequence!);
                    }
                  },
                );
              }(),
            ),
          ],
        ),
      );
    });
  }
}
