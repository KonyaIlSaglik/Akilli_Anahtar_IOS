import 'package:akilli_anahtar/dtos/home_device_dto.dart';

class DeviceGroupByBox {
  String boxName;
  List<HomeDeviceDto> devices;
  bool expanded;
  DeviceGroupByBox({
    required this.boxName,
    required this.devices,
    this.expanded = false,
  });
}
