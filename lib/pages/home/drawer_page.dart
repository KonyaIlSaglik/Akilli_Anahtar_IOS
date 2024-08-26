import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/pages/admin/admin_index_page.dart';
import 'package:akilli_anahtar/pages/device_manager/install/introduction_page.dart';
import 'package:akilli_anahtar/pages/device_manager/update/update_main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:akilli_anahtar/pages/sifre_degistir.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';

class DrawerPage extends StatefulWidget {
  DrawerPage({
    Key? key,
  }) : super(key: key);

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Obx(
      () {
        return Drawer(
          child: Column(
            children: [
              Container(
                color: goldColor,
                height: height * 0.30,
                child: SizedBox(
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
                        child: Center(
                          child: Text(
                            _authController.user.value.fullName.trim(),
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
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    if (_authController.operationClaims.any((c) =>
                        c.name == "developer" || c.name == "device_install"))
                      ExpansionTile(
                        title: Text("Cihaz Yönetimi"),
                        children: [
                          ListTile(
                            leading: Icon(Icons.settings_input_component),
                            title: Text("Kurulum"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      IntroductionPage(),
                                ),
                              );
                            },
                            trailing: Icon(Icons.chevron_right),
                          ),
                          ListTile(
                            leading: Icon(Icons.upgrade),
                            title: Text("Yazılım Güncelleme"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      UpdateMainPage(),
                                ),
                              );
                            },
                            trailing: Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    if (_authController.operationClaims
                        .any((c) => c.name == "developer" || c.name == "admin"))
                      ListTile(
                        leading: Icon(FontAwesomeIcons.userShield),
                        title: Text("Admin"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  AdminIndexPage(),
                            ),
                          );
                        },
                        trailing: Icon(Icons.chevron_right),
                      ),
                    ListTile(
                      leading: Icon(Icons.lock),
                      title: Text("Şifre Değiştir"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                SifreDegistirPage(),
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
                        await _authController.logOut();
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
      },
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
