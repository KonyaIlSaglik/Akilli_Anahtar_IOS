import 'package:akilli_anahtar/controllers/nodemcu_controller.dart';
import 'package:akilli_anahtar/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
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
          "Cihazı internete bağlamak için yukarıdaki listeden bir ağ seçin ve istenirse şifre girin.",
      image: Center(
        child: nodemcuController.apList.isEmpty
            ? CircularProgressIndicator()
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
                            title: Text(nodemcuController.apList[i].ssidName),
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
                                  nodemcuController.apSSID.value =
                                      nodemcuController.apList[i].ssidName;

                                  nodemcuController.apPass.value =
                                      passController.text;

                                  await nodemcuController.sendWifiSettings();
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
                itemCount: nodemcuController.apList.length,
              ),
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
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 18),
      ),
    );
  }
}
