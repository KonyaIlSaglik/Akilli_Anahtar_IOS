import 'package:akilli_anahtar/controllers/home_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  HomeController pageController = Get.find();
  @override
  Widget build(BuildContext context) {
    return CustomPopScope(
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Text(
            "Konya İl Sağlık Müdürlüğü",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text(
                "Değiştir",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                //
              },
            ),
          ],
        ),
      ),
    );
  }
}
