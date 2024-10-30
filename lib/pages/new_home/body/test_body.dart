import 'package:akilli_anahtar/controllers/home_controller.dart';
import 'package:akilli_anahtar/pages/new_home/body/horizontal_list.dart';
import 'package:akilli_anahtar/pages/new_home/body/organisation_select_list.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_device_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TestBody extends StatefulWidget {
  const TestBody({super.key});

  @override
  State<TestBody> createState() => _TestBodyState();
}

class _TestBodyState extends State<TestBody> {
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OrganisationSelectList(),
        Expanded(
          child: Obx(
            () {
              return homeController.grouping.value
                  ? Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemBuilder: (context, index) {
                        return HorizontalList(
                            listTitle:
                                homeController.groupedDevices[index].boxName,
                            titleOnPressed: () {
                              //
                            },
                            items: homeController.groupedDevices[index].devices
                                .map(
                              (d) {
                                return CustomDeviceCard(
                                  device: d,
                                );
                              },
                            ).toList());
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(height: height(context) * 0.02);
                      },
                      itemCount: homeController.groupedDevices.length);
            },
          ),
        ),
      ],
    );
  }
}
