import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/controllers/home_controller.dart';
import 'package:akilli_anahtar/pages/new_home/top/profil_card.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  HomeController homeController = Get.find();
  AuthController authController = Get.find();
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return CustomPopScope(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width(context) * 0.05),
          child: Obx(
            () {
              return Column(
                children: [
                  SizedBox(height: height(context) * 0.02),
                  ProfilCard(),
                  SizedBox(height: height(context) * 0.01),
                  Expanded(
                    child: pagesList[homeController.currentPage.value]!,
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex:
              homeController.currentPage.value == favoritePage ? 0 : 1,
          onTap: (value) {
            switch (value) {
              case 0:
                homeController.currentPage.value = favoritePage;
                homeController.savePageChanges();
                break;
              case 1:
                homeController.currentPage.value = testPage;
                homeController.savePageChanges();
                break;
              default:
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
              label: "Kurum",
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.user),
              activeIcon: Icon(FontAwesomeIcons.userLarge),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}
