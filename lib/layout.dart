import 'package:akilli_anahtar/controllers/home_controller.dart';
import 'package:akilli_anahtar/pages/home/drawer_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            title: Text(
              "AKILLI ANAHTAR",
              style: width(context) < minWidth
                  ? textTheme(context)
                      .titleMedium!
                      .copyWith(color: Colors.white)
                  : textTheme(context)
                      .titleLarge!
                      .copyWith(color: Colors.white),
            ),
            backgroundColor: primaryColor,
            actions: [
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.bell,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  //
                },
              )
            ],
          ),
          drawer: DrawerPage(),
          body: pagesList[homeController.currentPage.value],
        );
      },
    );
  }
}
