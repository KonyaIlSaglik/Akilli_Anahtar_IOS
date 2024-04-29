import 'package:akilli_anahtar/models/kullanici_giris_result.dart';
import 'package:akilli_anahtar/pages/home/datetime/date_view.dart';
import 'package:akilli_anahtar/pages/home/datetime/time_view.dart';
import 'package:akilli_anahtar/pages/home/tab_page/tab_view.dart';
import 'package:akilli_anahtar/pages/home/toolbar/toolbar_view.dart';
import 'package:flutter/material.dart';

import 'package:akilli_anahtar/utils/constants.dart';
import 'drawer_page.dart';

class HomePage extends StatefulWidget {
  final KullaniciGirisResult user;
  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        exitApp(context);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        drawer: DrawerPage(user: widget.user),
        body: Column(
          children: [
            Flexible(
              flex: 10,
              child: Toolbar(),
            ),
            Flexible(
              flex: 15,
              child: TimeView(),
            ),
            Flexible(
              flex: 7,
              child: DateView(),
            ),
            Flexible(
              flex: 73,
              child: TabView(user: widget.user),
            ),
          ],
        ),
      ),
    );
  }
}
