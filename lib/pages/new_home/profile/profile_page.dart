import 'package:akilli_anahtar/background_service.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/pages/new_home/profile/profile_page_device_list_item.dart';
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
  late List<HomeDeviceDto> sensors;
  var backgroundEnable = false;

  @override
  void initState() {
    super.initState();
    sensors = homeController.homeDevices.where((d) => d.typeId! < 4).toList();
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
              showModalBottomSheet(
                backgroundColor: Colors.brown[50],
                context: context,
                builder: (context) {
                  return Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(
                          "Cihazlar",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Divider(color: goldColor),
                        Expanded(
                          child: ListView.separated(
                            itemCount: sensors.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (context, index) {
                              var device = sensors[index];
                              return ProfilePageDeviceListItem(device: device);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Text("Cihazları Göster"),
          ),
        ),
      ],
    );
  }
}
