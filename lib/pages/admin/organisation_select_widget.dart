import 'package:akilli_anahtar/controllers/user_management_control.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrganisationSelectWidget extends StatefulWidget {
  const OrganisationSelectWidget({super.key});

  @override
  State<OrganisationSelectWidget> createState() =>
      _OrganisationSelectWidgetState();
}

class _OrganisationSelectWidgetState extends State<OrganisationSelectWidget> {
  UserManagementController userManagementControl = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return userManagementControl.organisations.isEmpty
          ? CircularProgressIndicator()
          : SizedBox(
              height: 60,
              child: DropdownSearch<Organisation>(
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(
                    hintText: "Kurum Seç",
                    border: OutlineInputBorder(),
                    // The suffix icon can be added to the decoration directly
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                ),
                items: (filter, loadProps) {
                  return userManagementControl.organisations;
                },
                selectedItem: userManagementControl.organisations
                    .firstWhereOrNull((o) =>
                        o.id ==
                        userManagementControl.selectedOrganisationId.value),
                itemAsString: (item) => item.name,
                onChanged: (value) {
                  if (value != null) {
                    userManagementControl.selectedOrganisationId.value =
                        value.id;
                    userManagementControl.filterBoxes();
                  }
                },
                filterFn: (item, filter) {
                  return item.name.toLowerCase().contains(filter.toLowerCase());
                },
                compareFn: (item1, item2) {
                  return item1.id == item2.id; // Compare based on the unique ID
                },
                // Add a clear button in the dropdown menu
                dropdownBuilder: (context, selectedItem) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          selectedItem != null
                              ? selectedItem.name
                              : "Kurum Seç",
                          style: TextStyle(
                              color: selectedItem != null
                                  ? Colors.black
                                  : Colors.grey),
                        ),
                      ),
                      if (selectedItem != null)
                        IconButton(
                          padding: EdgeInsets.only(bottom: 10),
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            // Clear selection
                            userManagementControl.selectedOrganisationId.value =
                                0; // Resetting the selected ID
                            userManagementControl
                                .filterBoxes(); // Optionally re-filter boxes
                          },
                        ),
                    ],
                  );
                },
              ),
            );
    });
  }
}
