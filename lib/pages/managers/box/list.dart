import 'package:akilli_anahtar/controllers/admin/box_management_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/pages/managers/box/box_detail/box_add_edit.dart';
import 'package:akilli_anahtar/pages/managers/box/list_item.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/organisation_select_widget.dart';
import 'package:flutter/material.dart';
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
  bool refreshing = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await boxManagementController.checkNewVersion();
      await boxManagementController.getBoxes();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        //
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: goldColor,
          elevation: 3,
          shadowColor: Colors.black,
          title: Text("Kutu Yönetimi"),
          foregroundColor: goldColor,
          actions: [
            IconButton(
                onPressed: () {
                  boxManagementController.selectedBox.value = Box();
                  Get.to(() => BoxAddEdit());
                },
                icon: Icon(Icons.add_box))
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60.0),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                children: [
                  OrganisationSelectWidget(
                    onChanged: () async {
                      await boxManagementController.checkNewVersion();
                      boxManagementController.getBoxes();
                      setState(() {});
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
              backgroundColor: goldColor,
              color: Colors.white,
              onRefresh: () async {
                setState(() {
                  refreshing = true;
                });
                await boxManagementController.checkNewVersion();
                await boxManagementController.getBoxes();
                setState(() {
                  refreshing = false;
                });
              },
              child: boxManagementController.loadingBox.value && !refreshing
                  ? Center(
                      child: CircularProgressIndicator(
                      color: goldColor,
                    ))
                  : boxManagementController.boxes.isEmpty
                      ? Center(child: Text("No boxes found."))
                      : ListView.separated(
                          itemBuilder: (context, i) {
                            return BoxListItem(
                              box: boxManagementController.boxes[i],
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider();
                          },
                          itemCount: boxManagementController.boxes.length,
                        ),
            );
          },
        ),
      ),
    );
  }
}
