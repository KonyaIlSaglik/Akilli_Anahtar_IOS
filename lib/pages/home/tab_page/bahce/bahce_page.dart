import 'package:akilli_anahtar/pages/home/tab_page/bahce/sensor_card.dart';
import 'package:akilli_anahtar/pages/home/tab_page/bahce/sulama_card.dart';
import 'package:akilli_anahtar/pages/home/tab_page/bahce/su_tank_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BahcePage extends StatefulWidget {
  const BahcePage({Key? key}) : super(key: key);

  @override
  State<BahcePage> createState() => _BahcePageState();
}

class _BahcePageState extends State<BahcePage> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(0.90)),
      child: WallLayout(
        stonePadding: 5,
        layersCount: 4,
        scrollDirection: Axis.vertical,
        stones: [
          Stone(
            id: 1,
            height: 1,
            width: 2,
            child: SensorCard(
                birim: "°C",
                icon: FontAwesomeIcons.temperatureThreeQuarters,
                title: "Sıcaklık",
                value: "25"),
          ),
          Stone(
            id: 2,
            height: 2,
            width: 2,
            child: BahceSuTankCard(top: 1000, value: 480),
          ),
          Stone(
            id: 3,
            height: 1,
            width: 2,
            child: SensorCard(
              birim: "%rh",
              title: "Nem",
              value: "45",
              icon: FontAwesomeIcons.droplet,
            ),
          ),
          Stone(
            id: 4,
            height: 1,
            width: 4,
            child: BahceSulamaCard(
              title: "Hat 1",
            ),
          ),
          Stone(
            id: 5,
            height: 1,
            width: 4,
            child: BahceSulamaCard(
              title: "Hat 2",
            ),
          ),
          Stone(
            id: 6,
            height: 1,
            width: 4,
            child: BahceSulamaCard(
              title: "Hat 3",
            ),
          ),
          Stone(
            id: 7,
            height: 1,
            width: 4,
            child: BahceSulamaCard(
              title: "Hat 4",
            ),
          ),
          Stone(
            id: 8,
            height: 1,
            width: 2,
            child: SensorCard(
                birim: "",
                icon: FontAwesomeIcons.arrowUpFromWaterPump,
                title: "Su Akış",
                value: "Akış Var"),
          ),
        ],
      ),
    );
  }
}
