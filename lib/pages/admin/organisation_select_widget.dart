import 'package:akilli_anahtar/controllers/claim_controller.dart';
import 'package:akilli_anahtar/controllers/user_controller.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrganisationSelectWidget extends StatefulWidget {
  const OrganisationSelectWidget({Key? key}) : super(key: key);

  @override
  State<OrganisationSelectWidget> createState() =>
      _OrganisationSelectWidgetState();
}

class _OrganisationSelectWidgetState extends State<OrganisationSelectWidget> {
  UserController userController = Get.find();
  ClaimController claimController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return claimController.organisations.isEmpty
          ? CircularProgressIndicator()
          : SizedBox(
              height: 60,
              child: DropdownSearch<Organisation>(
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: "Kurum Seç",
                    border: OutlineInputBorder(),
                    // The suffix icon can be added to the decoration directly
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                ),
                items: claimController.organisations,
                selectedItem: claimController.organisations.firstWhereOrNull(
                    (o) =>
                        o.id == claimController.selectedOrganisationId.value),
                itemAsString: (item) => item.name,
                onChanged: (value) {
                  if (value != null) {
                    claimController.selectedOrganisationId.value = value.id;
                    claimController.filterBoxes();
                  }
                },
                filterFn: (item, filter) {
                  return item.name.toLowerCase().contains(filter.toLowerCase());
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
                            claimController.selectedOrganisationId.value =
                                0; // Resetting the selected ID
                            claimController
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
