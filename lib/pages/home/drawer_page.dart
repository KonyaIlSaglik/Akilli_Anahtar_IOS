import 'dart:io';

import 'package:akilli_anahtar/models/kullanici_giris_result.dart';
import 'package:akilli_anahtar/pages/sifre_degistir.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../services/local/shared_prefences.dart';
import '../../utils/constants.dart';
import '../login_page.dart';

class DrawerPage extends StatefulWidget {
  final KullaniciGirisResult user;
  const DrawerPage({Key? key, required this.user}) : super(key: key);

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: mainColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: SizedBox(height: 0),
                        ),
                        Expanded(
                          flex: 3,
                          child: FittedBox(
                            child: CircleAvatar(
                              child: Icon(
                                Icons.person,
                                color: mainColor,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: SizedBox(height: 0),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            widget.user.adsoyad!,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .fontSize,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            widget.user.kad!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .fontSize,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: SizedBox(height: 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text("Şifre Değiştir"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => SifreDegistirPage(),
                      ),
                    );
                  },
                  trailing: Icon(Icons.chevron_right),
                ),
                // ListTile(
                //   leading: Icon(Icons.add_a_photo_outlined),
                //   title: Text("Resmi Değiştir"),
                //   onTap: () {
                //     //
                //   },
                //   trailing: Icon(Icons.chevron_right),
                // ),
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
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => LoginPage(),
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
