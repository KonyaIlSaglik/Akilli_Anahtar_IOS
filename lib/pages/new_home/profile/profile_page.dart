import 'package:akilli_anahtar/background_service.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  HomeController homeController = Get.find();
  var backgroundEnable = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    isRunning().then(
      (value) {
        setState(() {
          backgroundEnable = value;
        });
      },
    );

    var list = homeController.homeDevices;
    for (var device in list) {
      await LocalDb.get(notificationKey(device.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  backgroundEnable = false;
                });
              } else {
                await initializeService();
                init();
              }
            },
            child: Text(backgroundEnable ? "KAPAT" : "AÇ"),
          ),
        ),
        ListTile(
          title: Text("Sensör Bildirimleri"),
          trailing: TextButton(
              onPressed: () async {
                //
              },
              child: Text("Cihazları Göster")),
        ),
      ],
    );
  }
}
