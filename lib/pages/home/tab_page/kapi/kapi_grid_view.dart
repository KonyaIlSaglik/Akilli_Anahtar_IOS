import 'package:akilli_anahtar/pages/home/tab_page/kapi/kapi_item_active.dart';
import 'package:akilli_anahtar/pages/home/tab_page/kapi/kapi_item_pasive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';

import '../../../../models/kullanici_kapi_result.dart';

class KapiGridView extends StatelessWidget {
  final List<KullaniciKapiResult> kapilar;
  const KapiGridView({Key? key, required this.kapilar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WallLayout(
      stonePadding: 20,
      reverse: false,
      layersCount: 10,
      scrollDirection: Axis.vertical,
      stones: stoneList(),
    );
  }

  stoneList() {
    var list = <Stone>[];
    for (var i = 0; i < createList().length; i++) {
      list.add(
        Stone(
          id: i + 1,
          width: 5,
          height: 4,
          child: createList()[i],
        ),
      );
    }
    return list;
  }

  List<Widget> createList() {
    List<Widget> tempList = [];
    for (int i = 0; i < 6; i++) {
      tempList.add(KapiItemPasive());
    }
    if (kapilar.length < 6) {
      for (int i = 0; i < kapilar.length; i++) {
        tempList.removeLast();
      }
    }
    for (var kapi in kapilar) {
      tempList.add(KapiItemActive(kapi: kapi));
    }
    return tempList;
  }
}
