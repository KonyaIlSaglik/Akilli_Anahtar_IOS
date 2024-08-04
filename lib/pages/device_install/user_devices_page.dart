// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class UserDevicesPage extends StatefulWidget {
  const UserDevicesPage({Key? key}) : super(key: key);

  @override
  State<UserDevicesPage> createState() => _UserDevicesPageState();
}

class _UserDevicesPageState extends State<UserDevicesPage> {
  List<Box> boxes = List.empty();

  @override
  void initState() {
    super.initState();
    boxes = [
      Box(
        name: "AKILLI_ANAHTAR_12625837",
        devices: [
          Sensor(
            name: "Isı 1",
            cihaz_id: 29,
            cihaz_pin: "D4",
            tur: "isi",
            topic_stat: "topic1",
          ),
          Sensor(
            name: "Duman 1",
            cihaz_id: 83,
            cihaz_pin: "A0",
            tur: "duman",
            topic_stat: "topicA",
          ),
        ],
      ),
      Box(
        name: "AKILLI_ANAHTAR_10873378",
        devices: [
          Relay(
            name: "Kapı 1",
            cihaz_id: 1001,
            cihaz_pin: "D0",
            tur: "tek",
            topic_stat: "topic1_stat",
            topic_rec: "topic1_rec",
            topic_res: "topic1_res",
          ),
        ],
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: width * 0.80,
      height: height * 0.60,
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: boxes.length,
        itemBuilder: ((context, i) {
          return ExpansionTile(
            title: Text(boxes[i].name),
            children: boxes[i]
                .devices!
                .map(
                  (e) => ListTile(
                    title: Text(e.name),
                  ),
                )
                .toList(),
          );
        }),
      ),
    );
  }
}

class Box {
  String name;
  List<Device>? devices;
  Box({
    required this.name,
    this.devices,
  });
}

class Device {
  String name;
  int cihaz_id;
  String cihaz_pin;
  String tur;
  String topic_stat;
  Device({
    required this.name,
    required this.cihaz_id,
    required this.cihaz_pin,
    required this.tur,
    required this.topic_stat,
  });
}

class Sensor extends Device {
  String name;
  int cihaz_id;
  String cihaz_pin;
  String tur;
  String topic_stat;
  Sensor({
    required this.name,
    required this.cihaz_id,
    required this.cihaz_pin,
    required this.tur,
    required this.topic_stat,
  }) : super(name: '', cihaz_id: 0, cihaz_pin: '', tur: '', topic_stat: '');
}

class Relay extends Device {
  String name;
  int cihaz_id;
  String cihaz_pin;
  String tur;
  String topic_stat;
  String topic_rec;
  String topic_res;
  Relay({
    required this.name,
    required this.cihaz_id,
    required this.cihaz_pin,
    required this.tur,
    required this.topic_stat,
    required this.topic_rec,
    required this.topic_res,
  }) : super(name: '', cihaz_id: 0, cihaz_pin: '', tur: '', topic_stat: '');
}
