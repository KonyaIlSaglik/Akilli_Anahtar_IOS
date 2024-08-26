import 'package:akilli_anahtar/controllers/device_controller.dart';
import 'package:akilli_anahtar/models/control_device_model.dart';
import 'package:akilli_anahtar/pages/home/tab_page/kapi/barrier_door_item_4.dart';
import 'package:akilli_anahtar/pages/home/tab_page/kapi/light_item_5.dart';
import 'package:akilli_anahtar/pages/home/tab_page/kapi/null_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';
import 'package:get/get.dart';

class ControlDevicesPage extends StatefulWidget {
  const ControlDevicesPage({Key? key}) : super(key: key);

  @override
  State<ControlDevicesPage> createState() => _ControlDevicesPageState();
}

class _ControlDevicesPageState extends State<ControlDevicesPage> {
  ScrollController scrollController = ScrollController();
  List<ControlDeviceModel> controlDevices = [];
  final DeviceController _deviceController = Get.put(DeviceController());
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _deviceController.getControlDevices().then((value) {
      setState(() {
        controlDevices = _deviceController.controlDevices;
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          loading = true;
        });
        await _deviceController.getControlDevices();
        if (mounted) {
          setState(() {
            controlDevices = _deviceController.controlDevices;
            loading = false;
          });
        }
      },
      child: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Obx(() {
              return WallLayout(
                stonePadding: 20,
                reverse: false,
                layersCount: 10,
                scrollDirection: Axis.vertical,
                scrollController: scrollController,
                stones: stoneList(),
              );
            }),
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
    if (controlDevices.length < 6) {
      for (int i = 0; i < controlDevices.length; i++) {
        tempList.removeLast();
      }
    }
    for (var device in controlDevices) {
      if (device.deviceTypeId == 4) {
        tempList.add(BarrierDoorItem4(device: device));
      }
      if (device.deviceTypeId == 5) {
        tempList.add(LightItem5(device: device));
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
