import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/pages/home/drawer_page.dart';
import 'package:akilli_anahtar/pages/new_home/new_home_page.dart';
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
  @override
  void initState() {
    super.initState();
    print("Layout Created");
    Get.put(HomeController());
    Get.put(MqttController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.brown[50]!,
          foregroundColor: Colors.brown[50]!,
          elevation: 0,
          shadowColor: Colors.brown[50]!,
          iconTheme: IconThemeData(
            size: 30,
          ),
          title: Text(
            "AKILLI ANAHTAR",
            style: width(context) < minWidth
                ? textTheme(context).titleMedium!
                : textTheme(context).titleLarge!,
          ),
          actions: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.bell,
                size: 30,
              ),
              onPressed: () {
                //
              },
            )
          ],
        ),
        drawer: DrawerPage(),
        body: NewHomePage());
  }
}
