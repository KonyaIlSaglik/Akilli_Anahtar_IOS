import 'package:akilli_anahtar/controllers/update_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/pages/device_manager/update/box_list_item.dart';
import 'package:akilli_anahtar/pages/home/toolbar/toolbar_view.dart';
import 'package:akilli_anahtar/services/api/box_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateMainPage extends StatefulWidget {
  const UpdateMainPage({Key? key}) : super(key: key);

  @override
  State<UpdateMainPage> createState() => _UpdateMainPageState();
}

class _UpdateMainPageState extends State<UpdateMainPage> {
  UpdateController updateController = Get.put(UpdateController());
  var boxList = <Box>[];
  String newVersion = "";
  @override
  void initState() {
    super.initState();
    BoxService.getAll().then((value) {
      if (value != null) {
        setState(() {
          boxList = value;
        });
      }
    });
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
              ],
            ),
          ),
          Expanded(
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
                      TextButton(
                        onPressed: () {
                          //
                        },
                        child: Text(
                          "Tümünü Güncelle",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: boxList.isEmpty
                      ? Center(
                          child: Text("Liste boş"),
                        )
                      : ListView.separated(
                          itemBuilder: (context, i) {
                            return BoxListItem(box: boxList[i]);
                          },
                          separatorBuilder: (context, index) {
                            return Divider();
                          },
                          itemCount: boxList.length,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
