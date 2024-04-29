import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';

import 'sensor_list_item.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({Key? key}) : super(key: key);

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  String broker = 'red.oss.net.tr';
  int port = 1883;
  String clientIdentifier = 'mehmet';
  String topicIsi = "ISM/MSG/ISI";
  String topicNem = "ISM/MSG/NEM";
  String topicDuman = "ISM/MSG/DUMAN";
  List<SensorListItem> sensorList = [];
  @override
  void initState() {
    super.initState();
    sensorList.add(
      SensorListItem(
        id: 82,
        adi: "ISI",
        kurum: "KONYA ISM",
        durum: "Bağlı",
        deger: "25",
        birim: "C°",
        baglanti: 1,
      ),
    );
    sensorList.add(
      SensorListItem(
        id: 58,
        adi: "DUMAN",
        kurum: "KONYA ISM",
        durum: "Bağlı",
        deger: "Alarm Yok",
        birim: "",
        baglanti: 1,
      ),
    );
    sensorList.add(
      SensorListItem(
        id: 83,
        adi: "SU BASKINI",
        kurum: "KONYA ISM",
        durum: "Bağlı",
        deger: "Alarm Yok",
        birim: "",
        baglanti: 1,
      ),
    );
    sensorList.add(
      SensorListItem(
        id: 83,
        adi: "HAVA AKIŞ",
        kurum: "KONYA ISM",
        durum: "Bağlı",
        deger: "20",
        birim: "",
        baglanti: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(0.90)),
      child: WallLayout(
        stonePadding: 5,
        reverse: false,
        layersCount: 4,
        scrollDirection: Axis.vertical,
        stones: [
          Stone(
            id: 1,
            height: 1,
            width: 4,
            child: SensorListItem(
              id: 82,
              adi: "ISI",
              kurum: "KONYA ISM",
              durum: "Bağlı",
              deger: "25",
              birim: "C°",
              baglanti: 1,
            ),
          ),
          Stone(
            id: 2,
            height: 1,
            width: 4,
            child: SensorListItem(
              id: 82,
              adi: "NEM",
              kurum: "KONYA ISM",
              durum: "Bağlı",
              deger: "45",
              birim: "%rh",
              baglanti: 1,
            ),
          ),
          Stone(
            id: 3,
            height: 1,
            width: 4,
            child: SensorListItem(
              id: 58,
              adi: "DUMAN",
              kurum: "KONYA ISM",
              durum: "Bağlı",
              deger: "Alarm Yok",
              birim: "",
              baglanti: 1,
            ),
          ),
          Stone(
            id: 4,
            height: 1,
            width: 4,
            child: SensorListItem(
              id: 83,
              adi: "SU BASKINI",
              kurum: "KONYA ISM",
              durum: "Bağlı",
              deger: "Alarm Yok",
              birim: "",
              baglanti: 1,
            ),
          ),
          Stone(
            id: 5,
            height: 1,
            width: 4,
            child: SensorListItem(
              id: 83,
              adi: "HAVA AKIŞ",
              kurum: "KONYA ISM",
              durum: "Bağlı",
              deger: "Akış Var",
              birim: "",
              baglanti: 1,
            ),
          ),
          Stone(
            id: 6,
            height: 1,
            width: 4,
            child: SensorListItem(
              id: 82,
              adi: "Alev Sensörü",
              kurum: "KONYA ISM",
              durum: "Bağlı",
              deger: "Alev Yok",
              birim: "",
              baglanti: 1,
            ),
          ),
        ],
      ),
    );
  }
}
