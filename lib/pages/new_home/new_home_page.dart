import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/controllers/main/pager_controller.dart';
import 'package:akilli_anahtar/models/page_model.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  PagerController pagerController = Get.find();
  HomeController homeController = Get.find();
  AuthController authController = Get.find();
  MqttController mqttController = Get.find();
  int index = 0;

  @override
  void initState() {
    super.initState();
    print("HomePage Started");
    init();
  }

  init() async {
    await homeController.getData();

    if (mqttController.clientIsNull.value) {
      await mqttController.initClient();
    }
    if (!mqttController.isConnected.value) {
      await mqttController.connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: () async {
          await homeController.getData();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width(context) * 0.05),
          child: Obx(
            () {
              return homeController.loading.value ||
                      mqttController.clientIsNull.value ||
                      !mqttController.isConnected.value
                  ? Center(child: CircularProgressIndicator())
                  : PageModel.get(pagerController.currentPage.value)!.page;
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: goldColor,
        currentIndex:
            pagerController.currentPage.value == PageModel.favoritePage
                ? 0
                : pagerController.currentPage.value == PageModel.groupedPage
                    ? 1
                    : 2,
        onTap: (value) {
          switch (value) {
            case 0:
              pagerController.currentPage.value = PageModel.favoritePage;
              break;
            case 1:
              pagerController.currentPage.value = PageModel.groupedPage;
              break;
            default:
              pagerController.currentPage.value = PageModel.profilePage;
              break;
          }
          setState(() {});
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.heart),
            activeIcon: Icon(FontAwesomeIcons.solidHeart),
            label: "Favoriler",
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.city),
            activeIcon: Icon(FontAwesomeIcons.city),
            label: "Yerel",
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user),
            activeIcon: Icon(FontAwesomeIcons.userLarge),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
