import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/pager_controller.dart';
import 'package:akilli_anahtar/pages/box_install/install_settings.dart';
import 'package:akilli_anahtar/pages/user_manager/user_list_page.dart';
import 'package:akilli_anahtar/pages/auth/sifre_degistir.dart';
import 'package:akilli_anahtar/pages/box_manager/box_list_page.dart';
import 'package:akilli_anahtar/pages/box_install/introduction_page.dart';
import 'package:akilli_anahtar/widgets/version_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';

class DrawerPage extends StatefulWidget {
  DrawerPage({
    super.key,
  });

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  final AuthController _authController = Get.find();
  final PagerController pagerController = Get.find();
  @override
  void initState() {
    super.initState();
    print("Drawer initialized");
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
              Expanded(
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
                              await _authController.logOut(
                                  _authController.user.value.id,
                                  _authController
                                      .session.value.platformIdentity);
                            },
                            trailing: Icon(Icons.chevron_right),
                          ),
                          ListTile(
                            leading: Icon(Icons.upload_outlined),
                            title: Text("Uygulamayı Güncelle"),
                            onTap: () async {
                              checkNewVersion(context, true);
                            },
                            trailing: Icon(Icons.chevron_right),
                          ),
                          if (_authController.operationClaims.any((c) =>
                              c.name == "developer" ||
                              c.name == "device_install" ||
                              c.name == "admin"))
                            ExpansionTile(
                              leading: Icon(FontAwesomeIcons.userShield),
                              title: Text("Admin"),
                              children: [
                                if (_authController.operationClaims.any((c) =>
                                    c.name == "developer" ||
                                    c.name == "device_install"))
                                  ListTile(
                                    leading:
                                        Icon(Icons.settings_input_component),
                                    title: Text("Kutu Kurulum"),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder: (BuildContext context) =>
                                              InstallSettings(),
                                        ),
                                      );
                                    },
                                    trailing: Icon(Icons.chevron_right),
                                  ),
                                if (_authController.operationClaims.any((c) =>
                                    c.name == "developer" ||
                                    c.name == "device_install"))
                                  ListTile(
                                    leading: Icon(FontAwesomeIcons.upload),
                                    title: Text("Kutu Yönetimi"),
                                    onTap: () {
                                      Get.to(() => BoxListPage());
                                    },
                                    trailing: Icon(Icons.chevron_right),
                                  ),
                                ListTile(
                                  leading: Icon(FontAwesomeIcons.users),
                                  title: Text("Kullanıcı Yönetimi"),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            UserListPage(),
                                      ),
                                    );
                                  },
                                  trailing: Icon(Icons.chevron_right),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: VersionText(),
              ),
            ],
          ),
        );
      },
    );
  }

  gizlilikSozlesmesi() {
    final WebUri url = WebUri(gizlilikUrl);
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
