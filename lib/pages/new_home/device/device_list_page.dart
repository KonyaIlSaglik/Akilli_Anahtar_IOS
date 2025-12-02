import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item.dart';
import 'package:akilli_anahtar/pages/new_home/setting/box_management/add_box_onboarding_page.dart';
import 'package:akilli_anahtar/pages/new_home/setting/box_management/add_box_with_chipId.dart';
import 'package:akilli_anahtar/pages/new_home/setting/box_management/use_code_page.dart';
import 'package:akilli_anahtar/services/api/management_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:akilli_anahtar/pages/new_home/device/empty_device_page.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  HomeController homeController = Get.find();

  @override
  void initState() {
    super.initState();
    print("GrouppedPage");
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final groups = homeController.groupedDevices;
        final hasDevices = groups.any((g) => g.devices.isNotEmpty);
        return RefreshIndicator(
            onRefresh: () async {
              await homeController.getDevices();
            },
            child: hasDevices
                ? ListView.separated(
                    itemCount: homeController.groupedDevices.length,
                    shrinkWrap: true,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: height(context) * 0.01);
                    },
                    itemBuilder: (context, i) {
                      var g = homeController.groupedDevices[i];
                      return Visibility(
                        visible: g.devices.isNotEmpty,
                        child: Card(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white,
                                  Colors.white,
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(g.boxName),
                                    ],
                                  ),
                                ),
                                Divider(),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Column(
                                    children: [
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 3 / 2,
                                        ),
                                        itemCount: g.expanded
                                            ? g.devices.length
                                            : g.devices.length.clamp(0, 2),
                                        itemBuilder: (context, index) {
                                          final d = g.devices[index];
                                          return DeviceListViewItem(
                                            key: ValueKey(
                                                "${d.id}_${homeController.refreshTimestamp.value}"),
                                            device: d,
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ),
                                if (g.devices.length > 2)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        g.expanded = !g.expanded;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            g.expanded ? "Daralt" : "Genişlet"),
                                        Text(" (${g.devices.length})"),
                                        SizedBox(width: 5),
                                        Icon(
                                            g.expanded
                                                ? FontAwesomeIcons.angleUp
                                                : FontAwesomeIcons.angleDown,
                                            size: 20),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : EmptyDeviceCompact(
                    onAdd: () async {
                      await Get.to(() =>
                          const AddBoxOnboardingPage(allowSkipExit: true));
                      await Get.to(() => const AddBoxByChipIdPage());
                    },
                    onJoin: (String code) async {
                      print("Girilen kod: $code");
                      final result = await ManagementService.useShareCode(code);
                      if (result != null) {
                        successSnackbar("Başarılı", "Cihaz eklendi.");
                        await homeController.getDevices();
                      } else {
                        errorSnackbar("Hata", "Cihaz eklenemedi.");
                      }
                    },
                  ));
      },
    );
  }
}
