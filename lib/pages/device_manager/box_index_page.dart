import 'package:akilli_anahtar/controllers/box_management_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/pages/device_manager/box_list_item.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:turkish/turkish.dart';

class BoxIndexPage extends StatefulWidget {
  const BoxIndexPage({super.key});

  @override
  State<BoxIndexPage> createState() => _BoxIndexPageState();
}

class _BoxIndexPageState extends State<BoxIndexPage> {
  BoxManagementController boxManagementController =
      Get.put(BoxManagementController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      boxManagementController.getBoxes();
      boxManagementController.checkNewVersion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        boxManagementController.searchQuery.value = "";
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 3,
          shadowColor: Colors.black,
          title: Text("Kullanıcılar"),
          actions: [
            DropdownButton<String>(
              icon: Icon(
                FontAwesomeIcons.listUl,
                color: Colors.blue,
              ),
              dropdownColor: Colors.white,
              padding: EdgeInsets.only(top: 10),
              onChanged: (String? newValue) {
                setState(() {
                  boxManagementController.selectedSortOption.value = newValue!;
                  boxManagementController.sortBoxes();
                });
              },
              items: <String>['Sıra No', 'Ad Soyad', 'Kullanıcı Adı']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () {
                  boxManagementController.selectedBox.value = Box();
                  //Get.to(() => BoxAddEditPage());
                },
                icon: Icon(
                  FontAwesomeIcons.userPlus,
                  color: Colors.green,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60.0),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Ara',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (value) {
                  setState(() {
                    boxManagementController.searchQuery.value =
                        value.toLowerCase();
                  });
                },
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: boxManagementController.getBoxes,
          child: Obx(() {
            if (boxManagementController.loadingBox.value) {
              return Center(child: CircularProgressIndicator());
            } else if (boxManagementController.boxes.isEmpty) {
              return Center(child: Text("No users found."));
            } else {
              // Filter users based on the search query
              final filteredBoxes = boxManagementController.boxes.where((user) {
                return user.name.toLowerCaseTr().contains(
                        boxManagementController.searchQuery.value
                            .toLowerCaseTr()) ||
                    user.name.toLowerCaseTr().contains(boxManagementController
                        .searchQuery.value
                        .toLowerCaseTr());
              }).toList();
              return ListView.separated(
                itemBuilder: (context, i) {
                  return BoxListItem(box: filteredBoxes[i]);
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemCount: filteredBoxes.length,
              );
            }
          }),
        ),
      ),
    );
  }
}
