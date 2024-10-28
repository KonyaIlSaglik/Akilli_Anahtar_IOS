import 'package:akilli_anahtar/pages/new_home/body/vertical_list.dart';
import 'package:akilli_anahtar/widgets/custom_device_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VerticalList(
          listTitle: "Favoriler",
          titleOnPressed: () {
            //
          },
          items: [
            CustomDeviceCard(
              title: "SICAKLIK",
              status: "26",
              unit: "C°",
              iconData: FontAwesomeIcons.temperatureHalf,
              iconColor: Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}
