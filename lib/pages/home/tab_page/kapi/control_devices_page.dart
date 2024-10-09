import 'package:akilli_anahtar/controllers/device_controller.dart';
import 'package:akilli_anahtar/pages/home/tab_page/kapi/barrier_door_item_4.dart';
import 'package:akilli_anahtar/pages/home/tab_page/kapi/led_pin_item_9.dart';
import 'package:akilli_anahtar/pages/home/tab_page/kapi/light_item_5.dart';
import 'package:akilli_anahtar/pages/home/tab_page/kapi/null_item.dart';
import 'package:akilli_anahtar/pages/home/tab_page/kapi/rf_command_item_6.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';
import 'package:get/get.dart';

class ControlDevicesPage extends StatefulWidget {
  const ControlDevicesPage({super.key});

  @override
  State<ControlDevicesPage> createState() => _ControlDevicesPageState();
}

class _ControlDevicesPageState extends State<ControlDevicesPage> {
  DeviceController deviceController = Get.put(DeviceController());
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print("ControlDevicesPage Started.");
    Future.delayed(Duration.zero, () async {
      await deviceController.getUserDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: goldColor,
      onRefresh: () async {
        await deviceController.getUserDevices();
      },
      child: ListView(
        children: [
          Obx(() {
            return deviceController.loadingControlDevices.value
                ? Center(
                    child: CircularProgressIndicator(
                      color: goldColor,
                    ),
                  )
                : WallLayout(
                    stonePadding: 20,
                    reverse: false,
                    layersCount: 10,
                    scrollDirection: Axis.vertical,
                    scrollController: scrollController,
                    primary: false,
                    stones: stoneList(),
                  );
          }),
        ],
      ),
    );
  }

  List<Stone> stoneList() {
    var list = <Stone>[];
    for (var i = 0; i < createList().length; i++) {
      list.add(
        Stone(
          id: i + 1,
          width: 5,
          height: 4,
          child: createList()[i],
        ),
      );
    }

    return list;
  }

  List<Widget> createList() {
    List<Widget> tempList = [];
    for (int i = 0; i < 6; i++) {
      tempList.add(NullItem());
    }
    if (deviceController.controlDevices.length < 6) {
      for (int i = 0; i < deviceController.controlDevices.length; i++) {
        tempList.removeLast();
      }
    }
    for (var device in deviceController.controlDevices) {
      if (device.typeId == 4) {
        tempList.add(BarrierDoorItem4(device: device));
      }
      if (device.typeId == 5) {
        tempList.add(LightItem5(device: device));
      }
      if (device.typeId == 6) {
        tempList.add(RfCommandItem6(device: device));
      }
      if (device.typeId == 9) {
        tempList.add(LedPinItem9(device: device));
      }
    }
    toEnd();
    return tempList;
  }

  void toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
  }
}
