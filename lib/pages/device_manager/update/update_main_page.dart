import 'package:akilli_anahtar/controllers/update_controller.dart';
import 'package:akilli_anahtar/pages/device_manager/update/box_list_item.dart';
import 'package:akilli_anahtar/pages/home/toolbar/toolbar_view.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateMainPage extends StatefulWidget {
  const UpdateMainPage({super.key});

  @override
  State<UpdateMainPage> createState() => _UpdateMainPageState();
}

class _UpdateMainPageState extends State<UpdateMainPage> {
  UpdateController updateController = Get.put(UpdateController());
  @override
  void initState() {
    super.initState();
    updateController.onInit();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: height * 0.10,
        leadingWidth: width * 0.15,
        title: SizedBox(
          height: height * 0.10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Toolbar(),
              SizedBox(
                width: width * 0.05,
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.10),
                  child: Center(
                    child: Icon(
                      Icons.update,
                      color: goldColor,
                      size: 150,
                    ),
                  ),
                ),
                Obx(() {
                  return updateController.checkingNewVersion.value
                      ? CircularProgressIndicator()
                      : Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                      "Versiyon: ${updateController.newVersion.value.version}"),
                                  Text(updateController.newVersion.value.date),
                                ],
                              ),
                              ElevatedButton.icon(
                                label: Text("Yenile"),
                                icon: Icon(Icons.refresh),
                                onPressed: () {
                                  updateController.checkNewVersion();
                                },
                              ),
                            ],
                          ),
                        );
                }),
              ],
            ),
          ),
          Obx(() {
            return Expanded(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    color: goldColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Cihaz Listesi",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        // TextButton(
                        //   onPressed: () {
                        //     //
                        //   },
                        //   child: Text(
                        //     "Tümünü Güncelle",
                        //     style: TextStyle(
                        //       color: Colors.white70,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: updateController.checkingNewVersion.value
                        ? Center(
                            child: CircularProgressIndicator(
                              color: goldColor,
                            ),
                          )
                        : updateController.loadingBoxList.value
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: goldColor,
                                ),
                              )
                            : updateController.boxList.isEmpty
                                ? Center(
                                    child: Text("Liste boş"),
                                  )
                                : ListView.separated(
                                    itemBuilder: (context, i) {
                                      return BoxListItem(index: i);
                                    },
                                    separatorBuilder: (context, index) {
                                      return Divider();
                                    },
                                    itemCount: updateController.boxList.length,
                                  ),
                  ),
                ],
              ),
            );
          })
        ],
      ),
    );
  }
}
