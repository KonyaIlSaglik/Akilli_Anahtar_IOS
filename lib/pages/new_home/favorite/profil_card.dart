import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class ProfilCard extends StatefulWidget {
  final bool min;
  const ProfilCard({super.key, this.min = false});

  @override
  State<ProfilCard> createState() => _ProfilCardState();
}

class _ProfilCardState extends State<ProfilCard> {
  AuthController authController = Get.find();
  HomeController homeController = Get.find();

  @override
  void initState() {
    super.initState();
    homeController.getWather();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return SizedBox(
          height: height(context) * (widget.min ? 0.15 : 0.23),
          width: width(context),
          child: Card(
            elevation: 1,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/home_card_background.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: InkWell(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.cloudSunRain,
                              color: Colors.white70,
                            ),
                            SizedBox(width: width(context) * 0.03),
                            Text(
                              homeController.tempeture.value,
                              style: textTheme(context).titleLarge!.copyWith(
                                    color: Colors.white,
                                  ),
                            )
                          ],
                        ),
                        Text(
                          homeController.city.value,
                          style: textTheme(context).titleMedium!.copyWith(
                                color: Colors.white,
                              ),
                        )
                      ],
                    ),
                    onTap: () async {
                      var permission = await Geolocator.checkPermission();
                      if (permission == LocationPermission.denied) {
                        permission = await Geolocator.requestPermission();
                      }
                      if (permission != LocationPermission.denied) {
                        homeController.watherVisible.value = true;
                        await LocalDb.add(watherVisibleKey, "1");
                        await homeController.getWather();
                      }
                    },
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    authController.user.value.fullName!,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white, // Yazının rengi
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
