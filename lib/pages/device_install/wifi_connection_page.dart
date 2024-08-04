import 'dart:convert';

import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_button.dart';
import 'package:akilli_anahtar/widgets/custom_text_field.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class WifiConnectionPage extends StatefulWidget {
  const WifiConnectionPage({Key? key}) : super(key: key);
  @override
  State<WifiConnectionPage> createState() => _WifiConnectionPageState();
}

class _WifiConnectionPageState extends State<WifiConnectionPage> {
  var controller = TextEditingController();
  bool isConnected = false;
  bool scanning = true;
  List<String> ssidList = List.empty();
  @override
  void initState() {
    super.initState();
    WiFiForIoTPlugin.isConnected().then((value) async {
      if (value) {
        int page = 0;
        while (true) {
          var uri = Uri.parse("http://192.168.4.1/_ac/config?page=$page");
          var client = http.Client();
          var response = await client.get(uri);
          var doc = parse(response.body);
          var panelDiv = doc.body!.getElementsByClassName("base-panel")[0];
          var buttons = panelDiv
              .getElementsByTagName("input")
              .where((e) => e.attributes["type"] == "button")
              .toList();
          if (buttons.isEmpty) {
            setState(() {
              scanning = false;
            });
            break;
          } else {
            var list = buttons.map((e) => e.outerHtml
                .split("value=")[1]
                .replaceAll("\"", "")
                .replaceAll(">", ""));
            if (ssidList.isEmpty) {
              setState(() {
                ssidList = list.toList();
                print("Burada..........");
                scanning = false;
              });
            } else {
              ssidList.addAll(list);
            }
            page++;
          }
        }
      } else {
        setState(() {
          scanning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var passController = TextEditingController();
    final passwordFocus = FocusNode();
    var selectedSSID = "";
    return SizedBox(
      width: width * 0.80,
      height: height * 0.60,
      child: Card(
        color: goldColor,
        elevation: 5,
        child: Column(
          children: [
            ListTile(
              title: Text(
                "AKKILI ANAHTAR cihazınızı Kablosuz bir ağa bağlayın",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.qr_code,
                  color: Colors.white,
                ),
                onPressed: () {
                  // TODO: QR kod ile wifi bilgileri alınıp cihaza gönderilecek
                },
              ),
            ),
            Divider(color: Colors.white),
            Expanded(
              child: scanning
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : ssidList.isEmpty
                      ? Center(
                          child: Text("Wifi bulunamadı."),
                        )
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.90,
                          height: MediaQuery.of(context).size.height * 0.70,
                          child: ListView.separated(
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                            itemCount: ssidList.length,
                            itemBuilder: ((context, i) {
                              const color = Colors.white;
                              return ListTile(
                                visualDensity: VisualDensity.compact,
                                leading: Icon(Icons.wifi, color: color),
                                title: Text(
                                  ssidList[i],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: color),
                                ),
                                trailing: Icon(
                                  Icons.lock_outlined,
                                  color: Colors.white,
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedSSID = ssidList[i];
                                  });
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: goldColor,
                                      title: Text(selectedSSID),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CustomTextField(
                                            controller: passController,
                                            icon: Icon(Icons.lock),
                                            focusNode: passwordFocus,
                                            hintText: "Şifre",
                                            isPassword: true,
                                          ),
                                          CustomButton(
                                            title: "KAYDET",
                                            onPressed: () {
                                              var wifi = WifiSetting(
                                                wifiSsid: selectedSSID,
                                                wifiPassword:
                                                    passController.text,
                                              );
                                              var uri = Uri.parse(
                                                  "http://192.168.4.1/wifisettings");
                                              var client = http.Client();
                                              client
                                                  .post(
                                                uri,
                                                headers: {
                                                  'content-type':
                                                      'application/json',
                                                },
                                                body: wifi.toJson(),
                                              )
                                                  .then((response) {
                                                if (response.statusCode ==
                                                    200) {
                                                  CherryToast.success(
                                                    toastPosition:
                                                        Position.bottom,
                                                    title: Text(response.body),
                                                  ).show(context);
                                                } else {
                                                  CherryToast.error(
                                                    toastPosition:
                                                        Position.bottom,
                                                    title: Text(response.body),
                                                  ).show(context);
                                                }
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class WifiSetting {
  String? wifiSsid;
  String? wifiPassword;

  WifiSetting({this.wifiSsid, this.wifiPassword});

  WifiSetting.fromJson(Map<String, dynamic> json) {
    wifiSsid = json['wifi_ssid'];
    wifiPassword = json['wifi_password'];
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['wifi_ssid'] = wifiSsid;
    data['wifi_password'] = wifiPassword;
    return data;
  }
}
