import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ProfilCard extends StatefulWidget {
  const ProfilCard({super.key});

  @override
  State<ProfilCard> createState() => _ProfilCardState();
}

class _ProfilCardState extends State<ProfilCard> {
  AuthController authController = Get.find();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height(context) * 0.20,
      width: width(context) * 0.95,
      child: Card.outlined(
        elevation: 10,
        child: Padding(
          padding: EdgeInsets.all(height(context) * 0.02),
          child: Column(
            children: [
              SizedBox(
                height: height(context) * 0.10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Icon(
                          FontAwesomeIcons.city,
                          size: height(context) * 0.03,
                          color: Colors.deepPurple,
                        ),
                        Text(
                          "KONYA",
                          style: textTheme(context).titleMedium,
                        )
                      ],
                    ),
                    SizedBox(
                      height: height(context) * 0.08,
                      child: FittedBox(
                        child: CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          child: Icon(
                            FontAwesomeIcons.userLarge,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Icon(
                          FontAwesomeIcons.cloudSunRain,
                          size: height(context) * 0.03,
                          color: Colors.deepPurple,
                        ),
                        Text(
                          "- C°",
                          style: textTheme(context).titleMedium,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height(context) * 0.05,
                child: Center(
                  child: Text(
                    authController.user.value.fullName,
                    style: textTheme(context).titleLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
