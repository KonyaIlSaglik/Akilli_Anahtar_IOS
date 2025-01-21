import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VersionText extends StatefulWidget {
  const VersionText({super.key});

  @override
  State<VersionText> createState() => _VersionTextState();
}

class _VersionTextState extends State<VersionText> {
  String version = "";
  @override
  void initState() {
    super.initState();
    HomeController homeController = Get.put(HomeController());
    homeController.getVersion().then(
      (value) {
        setState(() {
          version = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "Versiyon: $version",
      style: TextStyle(color: goldColor),
    );
  }
}
