import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/pages/device_install/introduction_page.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:akilli_anahtar/pages/login_page2.dart';
import 'package:akilli_anahtar/pages/sifre_degistir.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class DrawerPage extends StatefulWidget {
  DrawerPage({
    Key? key,
  }) : super(key: key);

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  var loaded = false;
  late User user;
  var installVisible = false;
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setState(() {
      loaded = false;
    });
    var userInfo = await LocalDb.get(userKey);
    var claimsInfo = await LocalDb.get(userClaimsKey);
    setState(() {
      if (userInfo != null) {
        user = User.fromJson(userInfo);
      }
      if (claimsInfo != null) {
        installVisible = OperationClaim.fromJsonList(claimsInfo)
            .any((c) => c.name == "developer" || c.name == "device_install");
      }
      if (userInfo == null || claimsInfo == null) {
        CherryToast.error(
          toastPosition: Position.bottom,
          title: Text("Bir Sorun oldu. Lütfen tekrar giriş yapınız."),
        ).show(context);
        AuthService.logout().then((value) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => LoginPage2(),
            ),
          );
        });
      }
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Drawer(
      child: Column(
        children: [
          Container(
            color: goldColor,
            height: height * 0.30,
            child: loaded
                ? SizedBox(
                    width: width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: height * 0.05),
                          child: SizedBox(
                            height: height * 0.10,
                            child: FittedBox(
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: goldColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.05,
                          child: Text(
                            "user.fullName",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (installVisible)
                  ListTile(
                    leading: Icon(Icons.settings_input_component),
                    title: Text("Cihaz Kurulumu"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => IntroductionPage(),
                        ),
                      );
                    },
                    trailing: Icon(Icons.chevron_right),
                  ),
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
                  onTap: () async {
                    await AuthService.logout();
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => LoginPage2(),
                      ),
                    );
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
