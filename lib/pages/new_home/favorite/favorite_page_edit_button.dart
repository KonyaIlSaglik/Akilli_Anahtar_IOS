import 'package:akilli_anahtar/pages/new_home/favorite/favorite_edit_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class FavoritePageEditButton extends StatefulWidget {
  const FavoritePageEditButton({super.key});

  @override
  State<FavoritePageEditButton> createState() => _DeviceListViewItemState();
}

class _DeviceListViewItemState extends State<FavoritePageEditButton> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: Colors.grey,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Colors.brown[50]!,
                  Colors.brown[100]!,
                  Colors.brown[200]!,
                  Colors.brown[200]!,
                ],
              ),
            ),
          ),
          Positioned(
            left: 5,
            bottom: 5,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                FontAwesomeIcons.penToSquare,
                size: 40,
              ),
            ),
          ),
          Positioned(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width(context) * 0.02,
                vertical: width(context) * 0.01,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.to(FavoriteEditPage());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.penToSquare,
                                size: height(context) * 0.04,
                              ),
                              SizedBox(
                                height: height(context) * 0.01,
                              ),
                              Text(
                                "Düzenle",
                                style: textTheme(context).titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
