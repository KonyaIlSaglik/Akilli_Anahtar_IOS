import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/pages/managers/install/smart_config_page.dart';
import 'package:akilli_anahtar/pages/managers/user/user_list_page.dart';
import 'package:akilli_anahtar/pages/auth/sifre_degistir.dart';
import 'package:akilli_anahtar/pages/managers/box/list.dart';
import 'package:akilli_anahtar/widgets/version_text.dart';
import 'package:akilli_anahtar/dtos/session_dto.dart';
import 'package:akilli_anahtar/dtos/user_dto.dart';
import 'package:akilli_anahtar/splash_page.dart';
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
  final LoginController _loginController = Get.find();
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
                                  (_authController.user.value.fullName ??
                                          "Kullanıcı Adı")
                                      .trim(),
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
                            SizedBox(
                              height: height * 0.05,
                              child: Center(
                                child: Text(
                                  (_authController.user.value.userName ?? "")
                                      .trim(),
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
                            leading: Icon(FontAwesomeIcons.userLock),
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
                            leading: Icon(FontAwesomeIcons.arrowRightToBracket),
                            title: Text("Oturumdan Çık"),
                            onTap: () async {
                              await _authController.logOut(
                                  _authController.session.value.id,
                                  _loginController.deviceId.value,
                                  context: context);
                            },
                            trailing: Icon(Icons.chevron_right),
                          ),
                          ListTile(
                            leading: Icon(FontAwesomeIcons.circleArrowUp),
                            title: Text("Uygulamayı Güncelle"),
                            onTap: () async {
                              checkNewVersion(context, true);
                            },
                            trailing: Icon(Icons.chevron_right),
                          ),
                          if ((_authController.session.value.claims ?? [])
                              .any((e) => e == "device_install"))
                            Column(
                              children: [
                                ListTile(
                                  leading: Icon(FontAwesomeIcons.microchip),
                                  title: Text("Kutu Kurulum"),
                                  onTap: () {
                                    Get.to(() => SmartConfigPage());
                                  },
                                  trailing: Icon(Icons.chevron_right),
                                ),
                              ],
                            ),
                          if ((_authController.session.value.claims ?? [])
                              .any((e) => e == "developer"))
                            Column(
                              children: [
                                ListTile(
                                  leading: Icon(FontAwesomeIcons.server),
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
                          // if (_authController.operationClaims.any((c) =>
                          //     c.name == "developer" ||
                          //     c.name == "device_install" ||
                          //     c.name == "user_admin"))
                          //   ExpansionTile(
                          //     leading: Icon(FontAwesomeIcons.userShield),
                          //     title: Text("Admin"),
                          //     iconColor: goldColor,
                          //     children: [
                          //       if (_authController.operationClaims.any((c) =>
                          //           c.name == "developer" ||
                          //           c.name == "device_install"))
                          //         ListTile(
                          //           leading:
                          //               Icon(Icons.settings_input_component),
                          //           title: Text("Kutu Kurulum"),
                          //           onTap: () {
                          //             Navigator.push(
                          //               context,
                          //               MaterialPageRoute<void>(
                          //                 builder: (BuildContext context) =>
                          //                     InstallSettings(),
                          //               ),
                          //             );
                          //           },
                          //           trailing: Icon(Icons.chevron_right),
                          //         ),

                          //     ],
                          //   ),
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
            backgroundColor: Colors.white,
            shadowColor: goldColor,
            foregroundColor: goldColor,
            elevation: 10,
            title: Text(
              "GİZLİLİK POLİTİKASI",
              style: (width(context) < minWidth
                      ? textTheme(context).titleMedium!
                      : textTheme(context).titleLarge!)
                  .copyWith(color: goldColor),
            ),
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
        );
      },
    );
  }
}
