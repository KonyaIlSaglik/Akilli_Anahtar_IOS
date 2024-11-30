import 'dart:io';

import 'package:akilli_anahtar/utils/constants.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:udp/udp.dart';

class InstallSettings extends StatefulWidget {
  const InstallSettings({super.key});

  @override
  State<InstallSettings> createState() => _InstallSettingsState();
}

class _InstallSettingsState extends State<InstallSettings> {
  final TextEditingController ssidController =
      TextEditingController(text: "Zyxel_E0E9");
  final TextEditingController passwordController =
      TextEditingController(text: "KPT78MG4TL");
  final formKey = GlobalKey<FormState>();
  bool passVisible = false;
  bool _animate = false;
  var passwordFocus = FocusNode();

  Future<void> _startProvisioning() async {
    final provisioner = Provisioner.espTouch();

    provisioner.listen((response) {
      print(response.bssidText);
      print(response.ipAddressText);
      setState(() {
        _animate = false;
      });
    });

    provisioner.start(ProvisioningRequest.fromStrings(
      ssid: ssidController.text,
      bssid: '01:00:5E:00:00:00',
      password: passwordController.text,
    ));

    ProvisioningResponse? response = await showDialog<ProvisioningResponse>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Provisioning'),
          content: const Text('Provisioning started. Please wait...'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Stop'),
            ),
          ],
        );
      },
    );

    if (provisioner.running) {
      provisioner.stop();
      setState(() {
        _animate = false;
      });
    }

    if (response != null) {
      _onDeviceProvisioned(response);
    }
  }

  _onDeviceProvisioned(ProvisioningResponse response) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Device provisioned'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                  'Device successfully connected to the ${ssidController.text} network'),
              SizedBox.fromSize(size: const Size.fromHeight(20)),
              const Text('Device:'),
              Text('IP: ${response.ipAddressText}'),
              Text('BSSID: ${response.bssidText}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
      body: Column(
        children: [
          SizedBox(height: height(context) * 0.02),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(
                "Cihazın ağa bağlanabilmesi için ağ adı ve parolasını girin ve gönder butonuna basın. Ardından cihazdan cevap gelmesini bekleyin."),
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
                  SizedBox(
                    height: height(context) * 0.01,
                  ),
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
                  SizedBox(height: height(context) * 0.03),
                  SizedBox(
                    height: height(context) * 0.07,
                    width: width(context) * 0.50,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _animate = true;
                        });
                        _startProvisioning();
                      },
                      // onTap: () async {
                      //   var multicastEndpoint = Endpoint.broadcast(
                      //     port: Port(7001),
                      //   );

                      //   var receiver = await UDP.bind(multicastEndpoint);

                      //   var sender = await UDP.bind(Endpoint.any());

                      //   receiver.asStream().listen((datagram) {
                      //     if (datagram != null) {
                      //       var str = String.fromCharCodes(datagram.data);

                      //       print(str);
                      //     }
                      //   });

                      //   await sender.send(
                      //       '{"ssid":"BIMB","password":"admknh_066"}'.codeUnits,
                      //       multicastEndpoint);
                      // },
                      child: Card(
                        elevation: 10,
                        color: goldColor.withOpacity(0.7),
                        child: Center(
                          child: Text(
                            "GÖNDER",
                            style: textTheme(context)
                                .headlineLarge!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AvatarGlow(
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
                              child: Icon(
                                Icons.wifi,
                                color: Colors.white,
                                size: 75,
                              ),
                              radius: width(context) * 0.20,
                            ),
                          ),
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
    );
  }
}
