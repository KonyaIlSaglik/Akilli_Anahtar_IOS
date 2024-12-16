import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/pages/new_home/card_devices/device_grid_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupedPage extends StatefulWidget {
  const GroupedPage({super.key});

  @override
  State<GroupedPage> createState() => _GroupedPageState();
}

class _GroupedPageState extends State<GroupedPage> {
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Column(
          children: [
            //OrganisationSelectList(),
            homeController.grouping.value
                ? Center(
                    child: homeController.loading.value
                        ? null
                        : CircularProgressIndicator(),
                  )
                : Expanded(
                    child: ListView(
                      children: homeController.groupedDevices
                          .map(
                            (gd) => DeviceGridList(
                              deviceGroup: gd,
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
