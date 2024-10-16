import 'package:akilli_anahtar/controllers/home_controller.dart';
import 'package:akilli_anahtar/pages/home/tab_page/bahce/sulama_card.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';
import 'package:get/get.dart';

class BahcePage extends StatefulWidget {
  const BahcePage({super.key});

  @override
  State<BahcePage> createState() => _BahcePageState();
}

class _BahcePageState extends State<BahcePage> {
  HomeController deviceController = Get.put(HomeController());
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(0.90)),
      child: RefreshIndicator(
        color: goldColor,
        onRefresh: () async {
          await deviceController.getUserDevices();
        },
        child: ListView(
          children: [
            Obx(() {
              return deviceController.loadingDevices.value
                  ? Center(child: Center())
                  : deviceController.gardenDevices.isEmpty
                      ? Center(
                          child: Text("Liste Boş"),
                        )
                      : WallLayout(
                          stonePadding: 5,
                          layersCount: 4,
                          scrollDirection: Axis.vertical,
                          stones: deviceController.gardenDevices
                              .map((gardenDevice) {
                            return Stone(
                              id: gardenDevice.id,
                              height: 1,
                              width: 4,
                              child: BahceSulamaCard(
                                device: gardenDevice,
                              ),
                            );
                          }).toList(),
                        );
            }),
          ],
        ),
      ),
    );
  }
}
