import 'package:akilli_anahtar/background_service.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  HomeController homeController = Get.find();
  var text = "-";

  @override
  void initState() {
    super.initState();
    isRunning().then(
      (value) {
        setState(() {
          text = value ? "KAPAT" : "AÇ";
        });
      },
    );
    init();
  }

  void init() async {
    homeController.watherVisible.value =
        (await LocalDb.get(watherVisibleKey) ?? "0") == "1";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return ListView(
          children: [
            ListTile(
              title: Text("Arka Planda Çalışsın"),
              trailing: TextButton(
                  onPressed: () async {
                    var status = await isRunning();
                    if (status) {
                      stopBackgroundService();
                      setState(() {
                        text = "AÇ";
                      });
                    } else {
                      await initializeService();
                      setState(() {
                        text = "KAPAT";
                      });
                    }
                  },
                  child: Text(text)),
            ),
            ListTile(
              title: Text("Sensör Bildirimleri"),
              subtitle: Text("GPS izni gerektirir"),
              trailing: TextButton(
                  onPressed: () async {
                    //
                  },
                  child: Text(
                      homeController.watherVisible.value ? "Kapat" : "Aç")),
            ),
            ListTile(
              title: Text("Ana Sayfada Hava Durumu"),
              subtitle: Text("GPS izni gerektirir"),
              trailing: TextButton(
                  onPressed: () async {
                    if (homeController.watherVisible.value) {
                      homeController.watherVisible.value = false;
                      await LocalDb.add(watherVisibleKey, "0");
                    } else {
                      var permission = await Geolocator.checkPermission();
                      if (permission == LocationPermission.denied) {
                        permission = await Geolocator.requestPermission();
                      }
                      if (permission != LocationPermission.denied) {
                        homeController.watherVisible.value = true;
                        await LocalDb.add(watherVisibleKey, "1");
                        await homeController.getWather();
                      }
                    }
                  },
                  child: Text(
                      homeController.watherVisible.value ? "Kapat" : "Aç")),
            ),
          ],
        );
      },
    );
  }
}
