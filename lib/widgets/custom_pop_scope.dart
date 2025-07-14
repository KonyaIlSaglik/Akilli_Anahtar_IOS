// import 'package:akilli_anahtar/controllers/main/pager_controller.dart';
// import 'package:akilli_anahtar/pages/new_home/new_home_page.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class CustomPopScope extends StatelessWidget {
//   final Widget child;
//   final String? backPage;
//   const CustomPopScope({
//     super.key,
//     required this.child,
//     this.backPage,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) {
//         if (backPage != null) {
//         } else {
//           //exitApp(context);
//           Get.to(() => NewHomePage());
//         }
//       },
//       child: child,
//     );
//   }
// }
