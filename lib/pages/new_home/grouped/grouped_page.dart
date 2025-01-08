import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    return ListView(
      children: homeController.groupedDevices.map(
        (g) {
          return Card(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: RadialGradient(
                  colors: [
                    Colors.brown[50]!,
                    Colors.grey[200]!,
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
                  SizedBox(
                    width: width(context),
                    height: g.expanded
                        ? (width(context) * 0.26 * rowCount(g.devices.length)) +
                            width(context) * 0.07
                        : width(context) * 0.33,
                    child: Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: DeviceListView(
                          isHorizontal: !g.expanded,
                          title: "",
                          devices: g.devices,
                          count: g.expanded
                              ? g.devices.length
                              : g.devices.length > 3
                                  ? 3
                                  : g.devices.length,
                        ),
                      ),
                    ),
                  ),
                  if (g.devices.length > 3)
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
      ).toList(),
    );
  }

  rowCount(int count) {
    print("ccc $count");
    if (count <= 3) {
      return 1;
    }
    int row = (count / 3).ceil();
    return row;
  }
}
