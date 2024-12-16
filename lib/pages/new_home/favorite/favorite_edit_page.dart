import 'dart:ui';

import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class FavoriteEditPage extends StatefulWidget {
  const FavoriteEditPage({super.key});

  @override
  State<FavoriteEditPage> createState() => _FavoriteEditPageState();
}

class _FavoriteEditPageState extends State<FavoriteEditPage> {
  HomeController homeController = Get.find();
  late List<Device> devices;
  @override
  void initState() {
    super.initState();
    devices = homeController.favoriteDevices;
  }

  @override
  Widget build(BuildContext context) {
    final Color oddItemColor = goldColor.withOpacity(0.5);
    final Color evenItemColor = goldColor.withOpacity(0.15);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text("Favori Listesini Düzenle"),
        actions: [
          TextButton(
            child: Text("Kaydet"),
            onPressed: () {
              Get.back(result: true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(FontAwesomeIcons.circleInfo),
            title: Text(
                "Sırasını değiştirmek istediğiniz cihaza basılı tutarak yukarı ya da aşağı kaydırın."),
          ),
          Container(
            color: goldColor,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  child: Text(
                    "Favoriler",
                    style: textTheme(context).titleMedium!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: height(context) * 0.3,
            child: ReorderableListView.builder(
              itemCount: devices.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  key: Key('$index'),
                  tileColor: index.isOdd ? oddItemColor : evenItemColor,
                  leading: Icon(FontAwesomeIcons.solidHeart),
                  title: Text(devices[index].name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FontAwesomeIcons.sort),
                      InkWell(
                        child: Icon(
                          FontAwesomeIcons.xmark,
                          color: Colors.red.withOpacity(0.7),
                        ),
                        onTap: () {
                          //
                        },
                      ),
                    ],
                  ),
                );
              },
              onReorder: (int oldIndex, int newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                var device = devices.removeAt(oldIndex);
                devices.insert(newIndex, device);
                for (int i = 0; i < devices.length; i++) {
                  devices[i].favoriteSequence = i;
                }
              },
            ),
          ),
          Container(
            color: goldColor,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  child: Text(
                    "Tüm Bileşenler",
                    style: textTheme(context).titleMedium!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                var d = homeController.devices[index];
                return ListTile(
                  leading: Icon(FontAwesomeIcons.heart),
                  title: Text(d.name),
                  trailing: TextButton(
                    child: Text("Ekle"),
                    onPressed: () {
                      //
                    },
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(color: goldColor);
              },
              itemCount: homeController.devices.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          color: goldColor,
          shadowColor: goldColor,
          child: child,
        );
      },
      child: child,
    );
  }
}
