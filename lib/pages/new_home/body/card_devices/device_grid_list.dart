import 'package:akilli_anahtar/controllers/home_controller.dart';
import 'package:akilli_anahtar/models/device_group_by_box.dart';
import 'package:akilli_anahtar/pages/new_home/body/favorite/favorite_edit_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_device_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceGridList extends StatefulWidget {
  final DeviceGroupByBox deviceGroup;
  const DeviceGridList({
    super.key,
    required this.deviceGroup,
  });

  @override
  State<DeviceGridList> createState() => _DeviceGridListState();
}

class _DeviceGridListState extends State<DeviceGridList> {
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.deviceGroup.boxName,
              style: textTheme(context).titleMedium,
            ),
            TextButton(
              onPressed: widget.deviceGroup.expanded == null
                  ? () {
                      Get.to(() => FavoriteEditPage());
                    }
                  : widget.deviceGroup.expanded != null &&
                          widget.deviceGroup.devices.length < 3
                      ? null
                      : () {
                          setState(() {
                            if (widget.deviceGroup.expanded == null) {
                              //
                            } else {
                              widget.deviceGroup.expanded =
                                  !widget.deviceGroup.expanded!;
                            }
                          });
                        },
              child: Text(widget.deviceGroup.expanded == null
                  ? "Düzenle"
                  : widget.deviceGroup.devices.length < 3
                      ? ""
                      : widget.deviceGroup.expanded!
                          ? "Daralt"
                          : "Genişlet"),
            ),
          ],
        ),
        SizedBox(
          height: widget.deviceGroup.expanded != null &&
                  !widget.deviceGroup.expanded!
              ? height(context) * 0.20
              : height(context) * 0.40,
          child: RefreshIndicator(
            onRefresh: () async {
              await homeController.getData();
            },
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.deviceGroup.expanded != null &&
                        !widget.deviceGroup.expanded!
                    ? 1
                    : 2,
                crossAxisSpacing: widget.deviceGroup.expanded != null &&
                        !widget.deviceGroup.expanded!
                    ? 10
                    : 0,
                mainAxisSpacing: widget.deviceGroup.expanded != null &&
                        !widget.deviceGroup.expanded!
                    ? 10
                    : 0,
              ),
              scrollDirection: widget.deviceGroup.expanded != null &&
                      !widget.deviceGroup.expanded!
                  ? Axis.horizontal
                  : Axis.vertical,
              clipBehavior: Clip.none,
              children: widget.deviceGroup.devices.map(
                (d) {
                  return CustomDeviceCard(
                    device: d,
                  );
                },
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
