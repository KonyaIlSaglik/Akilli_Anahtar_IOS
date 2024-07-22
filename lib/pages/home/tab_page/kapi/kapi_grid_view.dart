import 'package:akilli_anahtar/models/kullanici_kapi.dart';
import 'package:akilli_anahtar/pages/home/tab_page/kapi/kapi_item_active.dart';
import 'package:akilli_anahtar/pages/home/tab_page/kapi/kapi_item_pasive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';

class KapiGridView extends StatefulWidget {
  final List<KullaniciKapi> kapilar;
  const KapiGridView({Key? key, required this.kapilar}) : super(key: key);

  @override
  State<KapiGridView> createState() => _KapiGridViewState();
}

class _KapiGridViewState extends State<KapiGridView> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WallLayout(
      stonePadding: 20,
      reverse: false,
      layersCount: 10,
      scrollDirection: Axis.vertical,
      scrollController: scrollController,
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
    if (widget.kapilar.length < 6) {
      for (int i = 0; i < widget.kapilar.length; i++) {
        tempList.removeLast();
      }
    }
    for (var kapi in widget.kapilar) {
      tempList.add(KapiItemActive(kapi: kapi));
    }
    toEnd();
    return tempList;
  }

  void toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
  }
}
