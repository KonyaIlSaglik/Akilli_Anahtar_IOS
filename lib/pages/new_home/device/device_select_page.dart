// import 'dart:convert';

// import 'package:akilli_anahtar/controllers/main/home_controller.dart';
// import 'package:akilli_anahtar/pages/new_home/favorite/device_list_view_item.dart';
// import 'package:akilli_anahtar/utils/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:home_widget/home_widget.dart';
// import 'dart:io' show Platform;

// class DeviceSelectPage extends StatefulWidget {
//   const DeviceSelectPage({super.key});

//   @override
//   State<DeviceSelectPage> createState() => _DeviceSelectPageState();
// }

// class _DeviceSelectPageState extends State<DeviceSelectPage> {
//   final HomeController homeController = Get.find();
//   int? selectedDeviceId;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       homeController.getDevices();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Color primaryColor = Theme.of(context).primaryColor;
//     final ColorScheme colorScheme = Theme.of(context).colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Cihaz Seç"),
//         backgroundColor: sheetBackground,
//         foregroundColor: colorScheme.onSurface,
//         elevation: 1,
//       ),
//       body: Obx(() {
//         final devices = homeController.groupedDevices
//             .expand((g) => g.devices)
//             .where((d) => d.typeId == 4 || d.typeId == 6)
//             .toList();

//         if (devices.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.devices_other,
//                   size: 64,
//                   color: colorScheme.onSurface.withOpacity(0.5),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   "Henüz uygun cihaz yok",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: colorScheme.onSurface.withOpacity(0.7),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Sadece kapı cihazları görüntülenir",
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: colorScheme.onSurface.withOpacity(0.5),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           );
//         }

//         return Column(
//           children: [
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: primaryColor.withOpacity(0.1),
//                 border: Border(
//                   bottom: BorderSide(
//                     color: primaryColor.withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.info_outline,
//                     color: primaryColor,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       "Widget için bir cihaz seçin",
//                       style: TextStyle(
//                         color: colorScheme.onSurface,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Expanded(
//               child: GridView.builder(
//                 padding: const EdgeInsets.all(16),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 0.9,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                 ),
//                 itemCount: devices.length,
//                 itemBuilder: (context, index) {
//                   final device = devices[index];
//                   final isSelected = selectedDeviceId == device.id;

//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedDeviceId = device.id;
//                       });
//                     },
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         side: BorderSide(
//                           color: isSelected ? primaryColor : Colors.transparent,
//                           width: 3,
//                         ),
//                       ),
//                       elevation: isSelected ? 4 : 2,
//                       shadowColor: isSelected
//                           ? primaryColor.withOpacity(0.3)
//                           : colorScheme.shadow,
//                       child: Stack(
//                         children: [
//                           // Cihaz içeriği - buton etkileşimini engelle
//                           AbsorbPointer(
//                             absorbing: true,
//                             child: DeviceListViewItem(device: device),
//                           ),

//                           // Seçim göstergesi
//                           if (isSelected)
//                             Positioned(
//                               top: 8,
//                               right: 8,
//                               child: Container(
//                                 padding: const EdgeInsets.all(4),
//                                 decoration: BoxDecoration(
//                                   color: primaryColor,
//                                   shape: BoxShape.circle,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: primaryColor.withOpacity(0.3),
//                                       blurRadius: 4,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: const Icon(
//                                   Icons.check,
//                                   size: 16,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),

//                           // Tıklanabilir overlay
//                           Positioned.fill(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(16),
//                                 color: isSelected
//                                     ? primaryColor.withOpacity(0.05)
//                                     : Colors.transparent,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // Seçim butonu
//             if (selectedDeviceId != null)
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: colorScheme.surface,
//                   border: Border(
//                     top: BorderSide(
//                       color: colorScheme.outline.withOpacity(0.1),
//                     ),
//                   ),
//                 ),
//                 child: ElevatedButton.icon(
//                   onPressed: () async {
//                     final selectedDevice =
//                         devices.firstWhere((d) => d.id == selectedDeviceId);

//                     final json = jsonEncode({
//                       'id': selectedDevice.id,
//                       'name': selectedDevice.name,
//                       'orgName': selectedDevice.organisationName,
//                       'status':
//                           homeController.lastStatus[selectedDevice.id] ?? '-',
//                       'typeId': selectedDevice.typeId,
//                       'boxId': selectedDevice.boxId,
//                       'unit': selectedDevice.unit ?? '',
//                       'rec': selectedDevice.topicRec,
//                       'open': selectedDevice.openingTime,
//                       'close': selectedDevice.closingTime,
//                       'wait': selectedDevice.waitingTime,
//                     });

//                     await HomeWidget.saveWidgetData<String>(
//                       'selectedDeviceJson',
//                       json,
//                     );

//                     print(
//                         "Cihaz widgete kaydedildi : ${selectedDevice.name}, ID: ${selectedDevice.id}, JSON: $json");

//                     await HomeWidget.updateWidget(
//                      // iOSName: 'HomeWidgetExtension',
//                       androidName: 'HomeWidgetProvider',
//                     );

//                     successSnackbar("Cihaz Seçildi",
//                         "${selectedDevice.name} widgete kaydedildi");

//                     const platform = MethodChannel('com.akillianahtar/widget');
//                     await platform.invokeMethod('reloadWidget');

//                     Future.delayed(const Duration(seconds: 2), () {
//                       if (Platform.isAndroid) {
//                         SystemNavigator.pop();
//                       }
//                     });
//                   },
//                   icon: const Icon(Icons.check_circle_outline),
//                   label: const Text(
//                     "Cihazı Seç ve Widget'e Ekle",
//                     style: TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(double.infinity, 56),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     elevation: 2,
//                     shadowColor: primaryColor.withOpacity(0.3),
//                   ),
//                 ),
//               ),
//           ],
//         );
//       }),
//     );
//   }
// }
