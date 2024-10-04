// import 'package:akilli_anahtar/controllers/nodemcu_controller.dart';
// import 'package:akilli_anahtar/utils/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:introduction_screen/introduction_screen.dart';

// class StartPageViewModel {
//   static PageViewModel get(context) {
//     final NodemcuController nodemcuController = Get.find();
//     var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;
//     return PageViewModel(
//       title: "HOŞGELİDİNİZ",
//       body:
//           "Kurulum işlemleri için wifi ile cihaza bağlamanız gerekmektedir. Devam ettiğinizde cihazdaki tüm veriler sıfırlanarak yeniden yüklenecektir.",
//       image: Center(
//         child: Image.asset(
//           "assets/anahtar.png",
//         ),
//       ),
//       footer: Obx(() {
//         return Column(
//           children: [
//             Center(
//               child: !nodemcuController.downloaded.value
//                   ? CircularProgressIndicator(
//                       color: goldColor,
//                     )
//                   : nodemcuController.boxDevicesIsEmpty.value
//                       ? Icon(
//                           Icons.remove_circle_outline,
//                           color: Colors.grey,
//                           size: 50,
//                         )
//                       : Icon(
//                           Icons.done,
//                           color: Colors.green,
//                           size: 50,
//                         ),
//             ),
//             SizedBox(
//               height: height * 0.01,
//             ),
//             Center(
//               child: !nodemcuController.downloaded.value
//                   ? Text("Lütfen bekleyin...")
//                   : nodemcuController.boxDevicesIsEmpty.value
//                       ? Text("Cihaz Listesi Bulunamadı. Destek ile görüşün.")
//                       : Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               "Devam etmek için ",
//                               style: TextStyle(
//                                 fontSize: 18,
//                               ),
//                             ),
//                             Text(
//                               "'Başla'",
//                               style: TextStyle(
//                                 color: goldColor,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                               ),
//                             ),
//                             Text(
//                               " butonuna basınız.",
//                               style: TextStyle(
//                                 fontSize: 18,
//                               ),
//                             ),
//                           ],
//                         ),
//             ),
//           ],
//         );
//       }),
//       decoration: PageDecoration(
//         footerFlex: 20,
//         bodyFlex: 40,
//         imageFlex: 40,
//         pageColor: Colors.white,
//         imagePadding: EdgeInsets.symmetric(horizontal: width * 0.10),
//         titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//         bodyTextStyle: TextStyle(fontSize: 18),
//       ),
//     );
//   }
// }
