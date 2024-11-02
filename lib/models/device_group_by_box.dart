// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:akilli_anahtar/entities/device.dart';

class DeviceGroupByBox {
  String boxName;
  List<Device> devices;
  bool? expanded;
  DeviceGroupByBox({
    required this.boxName,
    required this.devices,
    this.expanded,
  });
}
