// ignore_for_file: use_build_context_synchronously

import 'package:akilli_anahtar/models/kullanici_giris_result.dart';
import 'package:akilli_anahtar/pages/home/home_page.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/services/web/web_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_container.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:akilli_anahtar/pages/login_page.dart';
import 'package:xml/xml.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool load = false;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      initialization();
    }
  }

  void initialization() async {
    var info = await LocalDb.get(userKey);
    if (info == null) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => LoginPage(),
        ),
      );
      return;
    }
    var user =
        KullaniciGirisResult.fromXML(XmlDocument.parse(info).rootElement);
    var password = await LocalDb.get(passwordKey);
    if (password != null) {
      var isLogin = await WebService.kullaniciGiris(user.kad!, password);
      if (isLogin == null) {
        CherryToast.error(
          toastPosition: Position.bottom,
          title: Text("Oturum açılamadı. Lütfen tekrar giriş yapınız."),
        ).show(context);
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => LoginPage(),
          ),
        );
        return;
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => HomePage(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        //
      },
      child: Scaffold(
        body: CustomContainer(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(flex: 30, child: SizedBox(height: 0)),
              Expanded(flex: 20, child: Image.asset("assets/anahtar1.png")),
              Expanded(flex: 40, child: SizedBox(height: 0)),
              Expanded(flex: 1, child: Image.asset("assets/rdiot1.png")),
              Expanded(flex: 10, child: SizedBox(height: 0)),
            ],
          ),
        ),
      ),
    );
  }
}
