import 'package:akilli_anahtar/controllers/home_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class OrganisationSelectList extends StatefulWidget {
  const OrganisationSelectList({super.key});

  @override
  State<OrganisationSelectList> createState() => _OrganisationSelectListState();
}

class _OrganisationSelectListState extends State<OrganisationSelectList> {
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.building,
                  color: Colors.deepPurple,
                  size: height(context) * 0.03,
                ),
                SizedBox(width: width(context) * 0.01),
                Text(
                  homeController.selectedOrganisationId.value == 0
                      ? homeController.organisations.first.name
                      : homeController.organisations
                          .singleWhere(
                            (o) =>
                                o.id ==
                                homeController.selectedOrganisationId.value,
                          )
                          .name,
                  style: textTheme(context).titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            TextButton(
              child: Text(
                "Değiştir",
                style: textTheme(context)
                    .titleSmall!
                    .copyWith(color: Colors.deepPurple),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.80, // Adjust height as needed
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Title for the modal
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    "Kurum Listesi",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.pop(context); // Closes the modal
                                  },
                                ),
                              ],
                            ),
                            Divider(), // Optional divider for separation
                            Expanded(
                              child: Obx(() {
                                return ListView(
                                  children:
                                      homeController.organisations.map((o) {
                                    return ListTile(
                                      title: Text(o.name),
                                      trailing: homeController
                                                  .selectedOrganisationId
                                                  .value ==
                                              o.id
                                          ? null
                                          : TextButton(
                                              child: Text("Seç"),
                                              onPressed: () {
                                                homeController
                                                    .selectedOrganisationId
                                                    .value = o.id;
                                                homeController
                                                    .savePageChanges();
                                                homeController.groupDevices();
                                                Navigator.pop(context);
                                              },
                                            ),
                                    );
                                  }).toList(),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
