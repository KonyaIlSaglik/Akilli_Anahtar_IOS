import 'package:akilli_anahtar/controllers/nodemcu_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnlinePageViewModel {
  static PageViewModel get(context) {
    final NodemcuController nodemcuController = Get.find<NodemcuController>();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var passController = TextEditingController();
    final passFocus = FocusNode();
    return PageViewModel(
      title: "CİHAZ İNTERNET BAĞLANTISI",
      body:
          "Cihazı internete bağlamak için yukarıdaki listeden bir ağ seçin ve istenirse şifre girin ve bağlanmayı bekleyin. Tamamlandı butonuna bastığınızda cihaz yeniden başlatılacaktır.",
      image: Column(
        children: [
          Expanded(
            child: nodemcuController.apScanning.value
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : nodemcuController.apList.isEmpty
                    ? Center(
                        child: Text("Bağlanılabilecek bir ağ bulunamadı."),
                      )
                    : ListView.separated(
                        itemBuilder: (context, i) {
                          return ListTile(
                            title: Text(nodemcuController.apList[i].ssidName),
                            leading: Icon(
                              nodemcuController.apList[i].encType == "NONE"
                                  ? Icons.wifi
                                  : Icons.wifi_password,
                            ),
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: goldColor,
                                    title: Text(
                                      nodemcuController.apList[i].ssidName,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    content: CustomTextField(
                                      controller: passController,
                                      focusNode: passFocus,
                                      icon: Icon(Icons.lock),
                                      isPassword: true,
                                      autoFocus: true,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Vazgeç",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          nodemcuController.apSSID.value =
                                              nodemcuController
                                                  .apList[i].ssidName;

                                          nodemcuController.apPass.value =
                                              passController.text;

                                          await nodemcuController
                                              .sendWifiSettings();
                                        },
                                        child: Text(
                                          "Bağlan",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
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
                        itemCount: nodemcuController.apList.length,
                      ),
          ),
          Divider(
            thickness: 3,
            color: goldColor,
          ),
        ],
      ),
      footer: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: !nodemcuController.apConnected.value
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
                    size: 50,
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Text(
                    "Herşey Hazır",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
      ),
      decoration: PageDecoration(
        footerFlex: 15,
        bodyFlex: 30,
        imageFlex: 55,
        pageColor: Colors.white,
        imagePadding: EdgeInsets.all(24),
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 18),
      ),
    );
  }
}
