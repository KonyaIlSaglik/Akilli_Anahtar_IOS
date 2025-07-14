import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: Center(
        child: Text(
          'Ayarlar sayfası',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
        ),
      ),
    );
  }
}

// import 'dart:async';

// import 'package:akilli_anahtar/background_service.dart';
// import 'package:akilli_anahtar/controllers/main/home_controller.dart';
// import 'package:akilli_anahtar/dtos/home_device_dto.dart';
// import 'package:akilli_anahtar/pages/new_home/setting/settings_page_device_list_item.dart';
// import 'package:akilli_anahtar/services/local/shared_prefences.dart';
// import 'package:akilli_anahtar/utils/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class SettingsPage extends StatefulWidget {
//   const SettingsPage({super.key});

//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   HomeController homeController = Get.find();
//   late List<HomeDeviceDto> sensors;

//   bool serviceIsRunning = false;
//   String selectedNotificationRange = notificationRanges[0];

//   @override
//   void initState() {
//     super.initState();
//     sensors = homeController.homeDevices.where((d) => d.typeId! < 4).toList();
//     init();
//   }

//   void init() async {
//     var status = await isRunning();
//     setState(() {
//       serviceIsRunning = status;
//     });

//     String? notificationRange = await LocalDb.get(notificationRangeKey);
//     if (notificationRange != null) {
//       setState(() {
//         selectedNotificationRange = notificationRange;
//       });
//     } else {
//       await LocalDb.update(notificationRangeKey, selectedNotificationRange);
//     }

//     var list = homeController.homeDevices;
//     for (var device in list) {
//       await LocalDb.get(notificationKey(device.id!));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: [
//         SwitchListTile(
//           title: Text("Bildirimler"),
//           activeColor: Colors.white,
//           activeTrackColor: goldColor,
//           value: serviceIsRunning,
//           onChanged: (value) async {
//             if (value) {
//               setState(() {
//                 serviceIsRunning = true;
//               });
//               Timer.periodic(Duration(seconds: 1), (timer) async {
//                 if (!(await isRunning())) {
//                   timer.cancel();
//                   await initializeService();
//                 }
//               });
//             } else {
//               stopBackgroundService();
//               setState(() {
//                 serviceIsRunning = false;
//               });
//             }
//           },
//         ),
//         Divider(),
//         ListTile(
//           enabled: serviceIsRunning,
//           title: Text("Bildirim Aralığı (dk)"),
//           trailing: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: selectedNotificationRange,
//               onChanged: !serviceIsRunning
//                   ? null
//                   : (String? newValue) async {
//                       if (newValue == null) return;
//                       setState(() {
//                         selectedNotificationRange = newValue;
//                       });
//                       await LocalDb.update(
//                           notificationRangeKey, selectedNotificationRange);
//                       stopBackgroundService();
//                       Timer.periodic(Duration(seconds: 1), (timer) async {
//                         if (!(await isRunning())) {
//                           await initializeService();
//                           timer.cancel();
//                         }
//                       });
//                     },
//               items: notificationRanges
//                   .map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//         Divider(),
//         ListTile(
//           enabled: serviceIsRunning,
//           title: Text("Sensörlere Göre Bildirimler"),
//           trailing: TextButton(
//             onPressed: !serviceIsRunning
//                 ? null
//                 : () async {
//                     showModalBottomSheet(
//                       backgroundColor: Colors.brown[50],
//                       context: context,
//                       isScrollControlled: true,
//                       builder: (context) {
//                         return Container(
//                           padding: EdgeInsets.all(8),
//                           height: height(context) * 0.70,
//                           child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment
//                                     .spaceBetween, // Distribute space
//                                 children: [
//                                   Padding(
//                                     padding: EdgeInsets.only(left: 8),
//                                     child: Text(
//                                       "Sensörler",
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .headlineMedium,
//                                     ),
//                                   ),
//                                   IconButton(
//                                     icon: Icon(Icons.close),
//                                     onPressed: () {
//                                       Navigator.pop(context); // Close the modal
//                                     },
//                                   ),
//                                 ],
//                               ),
//                               Divider(color: goldColor),
//                               Expanded(
//                                 child: ListView.separated(
//                                   itemCount: sensors.length,
//                                   separatorBuilder: (context, index) =>
//                                       Divider(),
//                                   itemBuilder: (context, index) {
//                                     var device = sensors[index];
//                                     return ProfilePageDeviceListItem(
//                                         device: device);
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//             child: Text("Sensörler"),
//           ),
//         ),
//         Divider(),
//       ],
//     );
//   }
// }
