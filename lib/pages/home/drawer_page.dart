import 'dart:io';

import 'package:akilli_anahtar/models/kullanici_giris_result.dart';
import 'package:akilli_anahtar/pages/login_page2.dart';
import 'package:akilli_anahtar/pages/sifre_degistir.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class DrawerPage extends StatefulWidget {
  final KullaniciGirisResult user;
  const DrawerPage({Key? key, required this.user}) : super(key: key);

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: height * 0.30,
            child: Container(
              width: width,
              color: mainColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.10,
                    child: FittedBox(
                      child: CircleAvatar(
                        child: Icon(
                          Icons.person,
                          color: mainColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.05,
                    child: Text(
                      widget.user.adsoyad!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            Theme.of(context).textTheme.headlineSmall!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.05,
                    child: Text(
                      widget.user.kad!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            Theme.of(context).textTheme.titleLarge!.fontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text("Şifre Değiştir"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => SifreDegistirPage(),
                      ),
                    );
                  },
                  trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text("Uygulama Yardımı"),
                  onTap: () {
                    //
                  },
                  trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.shieldHalved),
                  title: Text("Gizlilik Politikası"),
                  onTap: () {
                    gizlilikSozlesmesi();
                  },
                  trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text("Oturumdan Çık"),
                  onTap: () {
                    LocalDb.delete(userKey);
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => LoginPage2(),
                      ),
                    );
                  },
                  trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: Icon(Icons.close),
                  title: Text("Uygulamayı Kapat"),
                  onTap: () {
                    LocalDb.delete(userKey);
                    exit(0);
                  },
                  trailing: Icon(Icons.chevron_right),
                ),
                Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  gizlilikSozlesmesi() {
    final Uri url = Uri.parse(gizlilikUrl);
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: mainColor,
          ),
          body: Center(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: url),
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(
                    action: ServerTrustAuthResponseAction.PROCEED);
              },
            ),
          ),
          persistentFooterAlignment: AlignmentDirectional.center,
          persistentFooterButtons: [
            ElevatedButton.icon(
              icon: Icon(
                Icons.arrow_back,
                color: mainColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              label: Text("Geri"),
            ),
          ],
        );
      },
    );
  }
}
