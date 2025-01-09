import 'dart:async';
import 'package:akilli_anahtar/controllers/install/wifi_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class InstallSettings extends StatefulWidget {
  const InstallSettings({super.key});

  @override
  State<InstallSettings> createState() => _InstallSettingsState();
}

class _InstallSettingsState extends State<InstallSettings> {
  WifiController wifiController = Get.put(WifiController());
  final TextEditingController ssidController = TextEditingController(text: "");
  final TextEditingController passwordController =
      TextEditingController(text: "");

  // final TextEditingController ssidController =
  //     TextEditingController(text: "CEKICI");
  // final TextEditingController passwordController =
  //     TextEditingController(text: "Yusuf42Sevil");

  // final TextEditingController ssidController =
  //     TextEditingController(text: "BIMB");
  // final TextEditingController passwordController =
  //     TextEditingController(text: "admknh_066");
  // final TextEditingController ssidController =
  //     TextEditingController(text: "Zyxel_E0E9");
  // final TextEditingController passwordController =
  //     TextEditingController(text: "KPT78MG4TL");
  final formKey = GlobalKey<FormState>();
  bool passVisible = false;
  final provisioner = Provisioner.espTouch();
  late Timer timer;
  bool _animate = false;
  int countDown = 0;
  var passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    var status = await Permission.locationWhenInUse.status.isGranted;
    if (!status) {
      status = await Permission.locationWhenInUse.request().isGranted;
    }

    if (status) {
      wifiController.getSSID().then(
        (value) {
          if (value.isNotEmpty) {
            setState(() {
              ssidController.text = value;
            });
          }
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stopProvisioning(close: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        iconTheme: IconThemeData(
          size: 30,
        ),
        elevation: 10,
        title: Text(
          "KURULUM",
          style: width(context) < minWidth
              ? textTheme(context).titleMedium!
              : textTheme(context).titleLarge!,
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: height(context) * 0.02),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text(
                  "Telefonu bir wifi ağına bağlayın. Cihazı wifi ağına bağlamak için ağ adı ve parolasını girin ve yayınlayın. Ardından cihazın bağlanmasını bekleyin."),
            ),
            SizedBox(height: height(context) * 0.02),
            Form(
              key: formKey,
              child: Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: height(context) * 0.07,
                      width: width(context) * 0.90,
                      child: Card.outlined(
                        elevation: 10,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: TextSelectionThemeData(
                                selectionHandleColor: goldColor),
                          ),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Zorunlu Alan";
                              }
                              return null;
                            },
                            controller: ssidController,
                            cursorColor: Colors.black,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (value) {
                              passwordFocus.requestFocus();
                            },
                            style: textTheme(context).titleLarge,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                FontAwesomeIcons.wifi,
                                size: 20,
                                color: goldColor,
                              ),
                              hintText: "SSID",
                              hintStyle: textTheme(context)
                                  .titleMedium!
                                  .copyWith(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height(context) * 0.01),
                    SizedBox(
                      height: height(context) * 0.07,
                      width: width(context) * 0.90,
                      child: Card.outlined(
                        elevation: 10,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: TextSelectionThemeData(
                                selectionHandleColor: goldColor),
                          ),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Zorunlu Alan";
                              }
                              return null;
                            },
                            controller: passwordController,
                            cursorColor: Colors.black,
                            textInputAction: TextInputAction.done,
                            focusNode: passwordFocus,
                            style: textTheme(context).titleLarge,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                FontAwesomeIcons.lock,
                                size: 20,
                                color: goldColor,
                              ),
                              hintText: "PAROLA",
                              hintStyle: textTheme(context)
                                  .titleMedium!
                                  .copyWith(color: Colors.grey),
                              suffixIcon: IconButton(
                                  icon: Icon(
                                    passVisible
                                        ? FontAwesomeIcons.eyeSlash
                                        : FontAwesomeIcons.eye,
                                    size: 20,
                                    color: goldColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      passVisible = !passVisible;
                                    });
                                  }),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height(context) * 0.05),
                    InkWell(
                      borderRadius: BorderRadius.circular(90),
                      onTap: () {
                        if (provisioner.running) {
                          _stopProvisioning();
                        } else {
                          if (formKey.currentState!.validate()) {
                            _startProvisioning();
                          }
                        }
                      },
                      child: AvatarGlow(
                        duration: Duration(seconds: 3),
                        glowCount: 3,
                        glowColor: goldColor,
                        glowShape: BoxShape.circle,
                        animate: _animate,
                        curve: Curves.fastOutSlowIn,
                        child: Material(
                          elevation: 10.0,
                          shape: CircleBorder(),
                          color: Colors.transparent,
                          child: CircleAvatar(
                            backgroundColor: goldColor,
                            radius: width(context) * 0.20,
                            child: Icon(
                              Icons.wifi,
                              color: Colors.white,
                              size: 75,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height(context) * 0.05),
                    Visibility(
                      visible: provisioner.running,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Kalan Süre: ",
                            style: textTheme(context).titleMedium,
                          ),
                          Text(
                            "$countDown",
                            style: textTheme(context)
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            " saniye",
                            style: textTheme(context).titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _stopProvisioning({bool close = false}) {
    if (provisioner.running) {
      timer.cancel();
      provisioner.stop();
      if (!close) {
        setState(() {
          _animate = false;
        });
      }
    }
  }

  Future<void> _startProvisioning() async {
    var bssid = await wifiController.getBSSID();
    provisioner.start(ProvisioningRequest.fromStrings(
      ssid: ssidController.text,
      bssid: bssid,
      password: passwordController.text,
    ));
    setState(() {
      _animate = true;
    });

    timer = Timer.periodic(
      Duration(seconds: 1),
      (t) {
        setState(() {
          countDown = 180 - t.tick;
        });
        if (countDown == 0) {
          _stopProvisioning();
        }
      },
    );
  }
}
