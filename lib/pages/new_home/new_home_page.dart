import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/controllers/home_controller.dart';
import 'package:akilli_anahtar/controllers/pager_controller.dart';
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
  PagerController pagerController = Get.find();
  HomeController homeController = Get.find();
  AuthController authController = Get.find();
  int index = 0;

  @override
  void initState() {
    super.initState();
    print("HomePage Started");
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScope(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Obx(
          () {
            return RefreshIndicator(
              onRefresh: () async {
                await homeController.getData();
              },
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: width(context) * 0.05),
                child: FutureBuilder<void>(
                  future: homeController.getData(),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return ListView(
                        children: [
                          SizedBox(height: height(context) * 0.02),
                          ProfilCard(),
                          SizedBox(height: height(context) * 0.01),
                          pagesList[pagerController.currentPage.value]!,
                        ],
                      );
                    }
                  },
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex:
              pagerController.currentPage.value == favoritePage ? 0 : 1,
          onTap: (value) {
            switch (value) {
              case 0:
                pagerController.currentPage.value = favoritePage;
                pagerController.savePageChanges();
                break;
              case 1:
                pagerController.currentPage.value = groupedPage;
                pagerController.savePageChanges();
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
              label: "Yerel",
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
