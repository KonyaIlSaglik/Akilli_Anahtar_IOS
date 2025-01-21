// import 'package:akilli_anahtar/entities/device.dart';
// import 'package:akilli_anahtar/pages/new_home/card_devices/barrier_device.dart';
// import 'package:akilli_anahtar/pages/new_home/card_devices/garden_device.dart';
// import 'package:akilli_anahtar/pages/new_home/card_devices/sensor_device.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:akilli_anahtar/utils/constants.dart';

// class CustomDeviceCard extends StatefulWidget {
//   final Device device;
//   const CustomDeviceCard({
//     super.key,
//     required this.device,
//   });

//   @override
//   State<CustomDeviceCard> createState() => _CustomDeviceCardState();
// }

// class _CustomDeviceCardState extends State<CustomDeviceCard> {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: width(context) * 0.30,
//       height: width(context) * 0.30,
//       child: selectDevice(widget.device),
//     );
//   }

//   selectDevice(Device device) {
//     switch (device.typeId) {
//       case 1:
//         return SensorDevice(
//           device: device,
//         );
//       case 4:
//         return BarrierDevice(
//           device: device,
//         );
//       case 5:
//         return SensorDevice(
//           device: device,
//         );
//       case 6:
//         return BarrierDevice(
//           device: device,
//         );
//       case 7:
//         return SensorDevice(
//           device: device,
//         );
//       case 8:
//         return GardenDevice(
//           device: device,
//         );
//       default:
//         return SensorDevice(
//           device: device,
//         );
//     }
//   }
// }
