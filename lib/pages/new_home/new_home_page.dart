import 'package:akilli_anahtar/controllers/home_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_digital_clock.dart';
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
  HomeController pageController = Get.find();
  @override
  Widget build(BuildContext context) {
    return CustomPopScope(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            SizedBox(height: height(context) * 0.02),
            SizedBox(
              height: height(context) * 0.30,
              width: width(context) * 0.95,
              child: Card(
                elevation: 10,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        FontAwesomeIcons.building,
                      ),
                      title: Text(
                        "Konya İl Sağlık Müdürlüğü",
                      ),
                      trailing: TextButton(
                        child: Text(
                          "Değiştir",
                        ),
                        onPressed: () {
                          //
                        },
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          height: height(context) * 0.10,
                          width: width(context) * 0.50,
                          child: FittedBox(
                            child: CustomDigitalClock(
                              isLive: true,
                              showSeconds: false,
                              format: "HH:mm",
                              textStyle:
                                  Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: height(context) * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width(context) * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: width(context) * 0.45,
                    height: width(context) * 0.45,
                    child: Card(
                      elevation: 10,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Icon(
                            FontAwesomeIcons.warehouse,
                            shadows: <Shadow>[
                              Shadow(color: Colors.green, blurRadius: 15.0)
                            ],
                            size: 40,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: width(context) * 0.04),
                  SizedBox(
                    width: width(context) * 0.45,
                    height: width(context) * 0.45,
                    child: Card(
                      elevation: 10,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height(context) * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width(context) * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: width(context) * 0.45,
                    height: width(context) * 0.45,
                    child: Card(
                      elevation: 10,
                    ),
                  ),
                  SizedBox(width: width(context) * 0.04),
                  SizedBox(
                    width: width(context) * 0.45,
                    height: width(context) * 0.45,
                    child: Card(
                      elevation: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
