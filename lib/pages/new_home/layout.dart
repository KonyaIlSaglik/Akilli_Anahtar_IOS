import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/pages/home/drawer_page.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/favorite_page.dart';
import 'package:akilli_anahtar/pages/new_home/grouped/grouped_page.dart';
import 'package:akilli_anahtar/pages/new_home/profile/profile_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/back_container.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  MqttController mqttController = Get.put(MqttController());
  HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    print("Layout Created");
    init();
  }

  init() async {
    await mqttController.initClient();
    await homeController.getDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[50]!,
        foregroundColor: Colors.brown[50]!,
        elevation: 0,
        scrolledUnderElevation: 0,
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
      body: PersistentTabView(
        handleAndroidBackButtonPress: false,
        backgroundColor: Colors.brown[50]!,
        navBarHeight: height(context) * 0.07,
        padding: EdgeInsets.all(height(context) * 0.01),
        navBarStyle: NavBarStyle.style6,
        context,
        screens: [
          BackContainer(child: FavoritePage()),
          BackContainer(child: GroupedPage()),
          //BackContainer(child: GroupedPage()),
          BackContainer(child: ProfilePage()),
        ],
        items: [
          customPersistentBottomNavBarItem(
            FontAwesomeIcons.heart,
            title: "Favoriler",
          ),
          customPersistentBottomNavBarItem(
            FontAwesomeIcons.memory,
            title: "Cihazlar",
          ),
          // customPersistentBottomNavBarItem(
          //   FontAwesomeIcons.clock,
          //   title: "Planlar",
          // ),
          customPersistentBottomNavBarItem(
            FontAwesomeIcons.solidUser,
            title: "Profil",
          ),
        ],
      ),
    );
  }

  PersistentBottomNavBarItem customPersistentBottomNavBarItem(
    IconData iconData, {
    String? title,
  }) {
    return PersistentBottomNavBarItem(
      icon: Icon(iconData),
      title: title,
      activeColorPrimary: goldColor,
      activeColorSecondary: goldColor,
      inactiveColorPrimary: Colors.black54,
      inactiveColorSecondary: Colors.black54,
    );
  }
}
