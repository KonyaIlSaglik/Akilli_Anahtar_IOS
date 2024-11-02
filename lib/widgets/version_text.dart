import 'package:akilli_anahtar/controllers/pager_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VersionText extends StatelessWidget {
  const VersionText({super.key});

  @override
  Widget build(BuildContext context) {
    PagerController pagerController = Get.find();
    return Text("Versiyon: ${pagerController.appVersion.value}");
  }
}
