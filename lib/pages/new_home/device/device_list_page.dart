import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
        return RefreshIndicator(
          onRefresh: () async {
            await homeController.getDevices();
          },
          child: ListView.separated(
            itemCount: homeController.groupedDevices.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(height: height(context) * 0.01);
            },
            itemBuilder: (context, i) {
              var g = homeController.groupedDevices[i];
              return Card(
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
                        padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(g.boxName),
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Column(
                          children: [
                            GridView.count(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              childAspectRatio: 3 / 2,
                              children: g.devices.length == 1
                                  ? [
                                      DeviceListViewItem(
                                          device: g.devices.first)
                                    ]
                                  : !g.expanded
                                      ? g.devices
                                          .getRange(0, 2)
                                          .map((d) =>
                                              DeviceListViewItem(device: d))
                                          .toList()
                                      : g.devices
                                          .map((d) =>
                                              DeviceListViewItem(device: d))
                                          .toList(),
                            ),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.expanded ? "Daralt" : "Genişlet"),
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
              );
            },
          ),
        );
      },
    );
  }
}
