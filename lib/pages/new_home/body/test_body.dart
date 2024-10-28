import 'package:akilli_anahtar/pages/new_home/body/horizontal_list.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_device_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TestBody extends StatefulWidget {
  const TestBody({super.key});

  @override
  State<TestBody> createState() => _TestBodyState();
}

class _TestBodyState extends State<TestBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HorizontalList(
          listTitle: "Sunucu Odası",
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
            CustomDeviceCard(
              title: "NEM",
              status: "35",
              unit: "%",
              iconData: FontAwesomeIcons.droplet,
              iconColor: Colors.blue,
            ),
            CustomDeviceCard(
              title: "HAVA AKIŞI",
              status: "VAR",
              iconData: FontAwesomeIcons.wind,
              iconColor: Colors.blueGrey,
            ),
            CustomDeviceCard(
              title: "HAVA KALİTESİ",
              status: "753",
              unit: "PPM",
              iconData: FontAwesomeIcons.airbnb,
              iconColor: Colors.green,
            ),
          ],
        ),
        SizedBox(height: height(context) * 0.02),
        HorizontalList(
          listTitle: "Yönetim Otopark",
          titleOnPressed: () {
            //
          },
          items: [
            CustomDeviceCard(
              title: "OTOPARK",
              status: "1",
              iconData: FontAwesomeIcons.squareParking,
              iconColor: Colors.indigo,
            ),
          ],
        ),
      ],
    );
  }
}
