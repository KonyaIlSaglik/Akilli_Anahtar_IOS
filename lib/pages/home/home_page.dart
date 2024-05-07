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

//TODO Widget yapılacak. Tekli ve Çoklu

// TODO Tab sekmeleri yetkiye bağlanacak

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return PopScope(
      onPopInvoked: (didPop) {
        exitApp(context);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: height * 0.10,
          iconTheme: IconThemeData(color: mainColor),
          leadingWidth: width * 0.15,
          title: SizedBox(
            height: height * 0.10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Toolbar(),
                SizedBox(
                  width: width * 0.05,
                ),
              ],
            ),
          ),
        ),
        drawer: DrawerPage(user: widget.user),
        body: Column(
          children: [
            SizedBox(
              height: height * 0.12,
              child: TimeView(),
            ),
            SizedBox(
              height: height * 0.08,
              child: DateView(),
            ),
            Expanded(
              child: TabView(user: widget.user),
            ),
          ],
        ),
      ),
    );
  }
}
