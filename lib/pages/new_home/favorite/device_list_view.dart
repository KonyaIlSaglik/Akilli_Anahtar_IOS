import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceListView extends StatefulWidget {
  final String title;
  final List<HomeDeviceDto> devices;
  final int count;
  final bool isHorizontal;
  const DeviceListView(
      {super.key,
      required this.title,
      required this.devices,
      required this.count,
      required this.isHorizontal});

  @override
  State<DeviceListView> createState() => _DeviceListViewState();
}

class _DeviceListViewState extends State<DeviceListView> {
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.isNotEmpty)
          Column(
            children: [
              Text(widget.title),
              SizedBox(height: height(context) * 0.01),
            ],
          ),
        Expanded(
          child: GridView.builder(
            scrollDirection:
                widget.isHorizontal ? Axis.horizontal : Axis.vertical,
            shrinkWrap: true,
            itemCount: widget.count < 4 ? widget.count : widget.devices.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.isHorizontal ? 1 : 3,
                childAspectRatio: 1,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5),
            itemBuilder: (context, i) {
              return DeviceListViewItem(device: widget.devices[i]);
            },
          ),
        ),
      ],
    );
  }
}
