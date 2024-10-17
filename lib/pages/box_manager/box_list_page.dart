import 'package:akilli_anahtar/controllers/box_management_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/pages/box_manager/box_detail/box_add_edit_page.dart';
import 'package:akilli_anahtar/widgets/organisation_select_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class BoxListPage extends StatefulWidget {
  const BoxListPage({super.key});

  @override
  State<BoxListPage> createState() => _BoxListPageState();
}

class _BoxListPageState extends State<BoxListPage> {
  BoxManagementController boxManagementController =
      Get.put(BoxManagementController());
  Organisation? selectedOrganisation;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      boxManagementController.getBoxes();
      setState(() {});
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
                  Get.to(() => BoxAddEditPage());
                },
                icon: Icon(
                  FontAwesomeIcons.userPlus,
                  color: Colors.green,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(120.0),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                children: [
                  OrganisationSelectWidget(
                    onChanged: () async {
                      boxManagementController.searchQuery.value = "";
                      await boxManagementController.getBoxes();
                      setState(() {});
                    },
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Ara',
                      border: OutlineInputBorder(),
                      fillColor: Colors.transparent,
                      filled: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        boxManagementController.searchQuery.value =
                            value.toLowerCase();
                        boxManagementController.filterBoxes();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Obx(
          () {
            return RefreshIndicator(
              onRefresh: boxManagementController.getBoxes,
              child: boxManagementController.loadingBox.value
                  ? Center(child: CircularProgressIndicator())
                  : boxManagementController.boxes.isEmpty
                      ? Center(child: Text("No boxes found."))
                      : ListView.separated(
                          itemBuilder: (context, i) {
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(boxManagementController
                                    .filteredBoxes[i].id
                                    .toString()), // Display user ID
                              ),
                              title: Text(boxManagementController
                                  .filteredBoxes[i].name),
                              subtitle: Text(boxManagementController
                                  .filteredBoxes[i].name),
                              trailing: IconButton(
                                icon: Icon(Icons.chevron_right),
                                onPressed: () {
                                  boxManagementController.selectedBox.value =
                                      boxManagementController.filteredBoxes[i];
                                  Get.to(() => BoxAddEditPage());
                                },
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider();
                          },
                          itemCount:
                              boxManagementController.filteredBoxes.length,
                        ),
            );
          },
        ),
      ),
    );
  }
}
