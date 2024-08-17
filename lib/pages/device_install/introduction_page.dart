import 'package:akilli_anahtar/controllers/nodemcu_controller.dart';
import 'package:akilli_anahtar/controllers/wifi_controller.dart';
import 'package:akilli_anahtar/pages/device_install/user_devices_page.dart';
import 'package:akilli_anahtar/pages/device_install/wifi_connection_page.dart';
import 'package:akilli_anahtar/pages/home/home_page.dart';
import 'package:akilli_anahtar/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final WifiController _wifiController = Get.put(WifiController());
  final NodemcuController _nodemcuController = Get.put(NodemcuController());
  var passController = TextEditingController();
  final passFocus = FocusNode();
  var chipId = 0;
  int page = 0;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Obx(
      () {
        return IntroductionScreen(
          canProgress: (page) {
            if (page == 0 && !_wifiController.isConnected.value) {
              return false;
            }
            return true;
          },
          showBackButton: page != 2,
          back: Text("Geri"),
          controlsPadding: EdgeInsets.only(top: 50),
          showNextButton: (page == 0 && _wifiController.isConnected.value) ||
              (page == 1 && _nodemcuController.infoModel.value.haveDevices),
          next: Text("Sonraki"),
          showSkipButton: page == 2,
          skip: Text("Geç"),
          done: const Text("Tamamlandı"),
          onDone: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
          onChange: (value) async {
            setState(() {
              page = value;
            });
            if (value == 1) {
              await _nodemcuController.sendDeviceSetting();
            }
            if (value == 2) {
              await _nodemcuController.getNodemcuApList();
              print("_nodemcuController.apList.length");
              print(_nodemcuController.apList.length);
            }
          },
          pages: [
            PageViewModel(
              title: "HOŞGELİDİNİZ",
              body:
                  "Telefonunuzun Wifi Ayarları na giderek AKILLI ANAHTAR cihazına bağlantı kurunuz. Bağlantı sonrası bu sayfaya geri gelerek kurulum işlemlerine devam edebilirsiniz.",
              image: Center(
                child: Icon(
                  _wifiController.isConnected.value
                      ? Icons.wifi
                      : Icons.wifi_off,
                  size: 100.0,
                  color: Colors.blue,
                ),
              ),
              footer: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: _wifiController.isConnected.value
                    ? Column(
                        children: [
                          Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Text("Bağlısınız. Sonraki adıma geçebilirsiniz.")
                        ],
                      )
                    : Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Text("Cihaza bağlanma bekleniyor.")
                        ],
                      ),
              ),
              decoration: PageDecoration(
                footerFlex: 10,
                bodyFlex: 40,
                imageFlex: 50,
                pageColor: Colors.white,
                imagePadding: EdgeInsets.all(24),
                titleTextStyle:
                    TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                bodyTextStyle: TextStyle(fontSize: 18),
              ),
            ),
            PageViewModel(
              title: "CİHAZ KURULUMU",
              body:
                  "Lütfen verilerin cihaza aktarılmasını bekleyiniz. Yükleme işlemi tamamlanınca bir sonraki adıma geçebilirsiniz.",
              image: Center(
                child: Icon(
                  _wifiController.isConnected.value &&
                          _nodemcuController.boxDevices.value.box == null
                      ? Icons.sync_disabled
                      : Icons.sync,
                  size: 100.0,
                  color: Colors.blue,
                ),
              ),
              footer: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: _wifiController.isConnected.value &&
                        !_nodemcuController.infoModel.value.haveDevices
                    ? Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Text("Veri aktarımı bekleniyor.")
                        ],
                      )
                    : Column(
                        children: [
                          Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Text(
                              "Veri aktarımı başarılı. Sonraki adıma geçebilirsiniz.")
                        ],
                      ),
              ),
              decoration: PageDecoration(
                footerFlex: 10,
                bodyFlex: 30,
                imageFlex: 60,
                pageColor: Colors.white,
                imagePadding: EdgeInsets.all(24),
                titleTextStyle:
                    TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                bodyTextStyle: TextStyle(fontSize: 18),
              ),
            ),
            PageViewModel(
              title: "CİHAZ İNTERNET BAĞLANTISI",
              body:
                  "Cihazı internete bağlamak için yukarıdaki listeden bir ağ seçin ve istenirse şifre girin.",
              image: Center(
                child: _nodemcuController.apList.isEmpty
                    ? CircularProgressIndicator()
                    : ListView.separated(
                        itemBuilder: (context, i) {
                          return ListTile(
                            title: Text(_nodemcuController.apList[i].ssidName),
                            leading: Icon(
                              _nodemcuController.apList[i].encType == "NONE"
                                  ? Icons.wifi
                                  : Icons.wifi_password,
                            ),
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                        _nodemcuController.apList[i].ssidName),
                                    content: CustomTextField(
                                      controller: passController,
                                      focusNode: passFocus,
                                      icon: Icon(Icons.lock),
                                      isPassword: true,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          //
                                        },
                                        child: Text("Vazgeç"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          _nodemcuController.apSSID.value =
                                              _nodemcuController
                                                  .apList[i].ssidName;

                                          _nodemcuController.apPass.value =
                                              passController.text;

                                          await _nodemcuController
                                              .sendWifiSettings();
                                          Navigator.pop(context);
                                        },
                                        child: Text("Bağlan"),
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                        itemCount: _nodemcuController.apList.length,
                      ),
              ),
              footer: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: !_nodemcuController.apConnected.value
                    ? Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Text("İnternet Bağlantısı bekleniyor.")
                        ],
                      )
                    : Column(
                        children: [
                          Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Text(
                              "Cihaz İnternete bağlantı. Sonraki adıma geçebilirsiniz.")
                        ],
                      ),
              ),
              decoration: PageDecoration(
                footerFlex: 10,
                bodyFlex: 40,
                imageFlex: 50,
                pageColor: Colors.white,
                imagePadding: EdgeInsets.all(24),
                titleTextStyle:
                    TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                bodyTextStyle: TextStyle(fontSize: 18),
              ),
            ),
            PageViewModel(
              decoration: PageDecoration(
                titlePadding: EdgeInsets.symmetric(vertical: height * 0.05),
                footerFlex: 10,
                bodyFlex: 70,
                imageFlex: 30,
              ),
              title: "",
              bodyWidget: UserDevicesPage(),
            ),
          ],
        );
      },
    );
  }
}
