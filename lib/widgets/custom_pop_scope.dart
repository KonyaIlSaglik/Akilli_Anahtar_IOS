import 'package:akilli_anahtar/controllers/pager_controller.dart';
import 'package:akilli_anahtar/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomPopScope extends StatelessWidget {
  final Widget child;
  final String? backPage;
  const CustomPopScope({
    super.key,
    required this.child,
    this.backPage,
  });

  @override
  Widget build(BuildContext context) {
    PagerController pageController = Get.find();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (backPage != null) {
          pageController.currentPage.value = backPage!;
        } else {
          //exitApp(context);
          Get.to(HomePage());
        }
      },
      child: child,
    );
  }
}
