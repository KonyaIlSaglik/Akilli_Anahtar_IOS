// import 'package:akilli_anahtar/controllers/nodemcu_controller.dart';
// import 'package:akilli_anahtar/controllers/wifi_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:introduction_screen/introduction_screen.dart';

// class NodemcuPageViewModel {
//   static PageViewModel get(context) {
//     final WifiController wifiController = Get.find<WifiController>();
//     final NodemcuController nodemcuController = Get.find<NodemcuController>();
//     var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;
//     return PageViewModel(
//       title: "CİHAZ KURULUMU",
//       body:
//           "Lütfen verilerin cihaza aktarılmasını bekleyiniz. Yükleme işlemi tamamlanınca bir sonraki adıma geçebilirsiniz.",
//       image: Center(
//         child: Icon(
//           wifiController.isConnected.value &&
//                   nodemcuController.boxDevices.value.box == null
//               ? Icons.sync_disabled
//               : Icons.sync,
//           size: 100.0,
//           color: Colors.blue,
//         ),
//       ),
//       footer: Padding(
//         padding: EdgeInsets.symmetric(horizontal: width * 0.05),
//         child: wifiController.isConnected.value &&
//                 !nodemcuController.infoModel.value.haveDevices
//             ? Column(
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(
//                     height: height * 0.01,
//                   ),
//                   Text("Veri aktarımı bekleniyor.")
//                 ],
//               )
//             : Column(
//                 children: [
//                   Icon(
//                     Icons.done,
//                     color: Colors.green,
//                     size: 50,
//                   ),
//                   SizedBox(
//                     height: height * 0.01,
//                   ),
//                   Text(
//                     "Tamamlandı. Sonraki adıma geçebilirsiniz.",
//                     style: TextStyle(
//                       fontSize: 18,
//                     ),
//                   )
//                 ],
//               ),
//       ),
//       decoration: PageDecoration(
//         footerFlex: 20,
//         bodyFlex: 40,
//         imageFlex: 40,
//         pageColor: Colors.white,
//         imagePadding: EdgeInsets.all(24),
//         titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//         bodyTextStyle: TextStyle(fontSize: 18),
//       ),
//     );
//   }
// }
